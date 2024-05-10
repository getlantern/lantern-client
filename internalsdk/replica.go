package internalsdk

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"net/url"
	"strconv"
	"sync"
	"time"

	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/flashlight/v7/proxied"
	replicaConfig "github.com/getlantern/replica/config"
	replicaServer "github.com/getlantern/replica/server"
	replicaService "github.com/getlantern/replica/service"

	"github.com/getlantern/lantern-client/internalsdk/analytics"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/doh"

	"github.com/gorilla/mux"
)

// Replica HTTP Server that handles Replica API requests on localhost at a random port.
type ReplicaServer struct {
	analyticsSession analytics.Session

	ConfigDir  string
	Flashlight *flashlight.Flashlight
	Session    Session
	UserConfig common.UserConfig

	startOnce sync.Once
}

// Checks whether Replica should be enabled and lazily starts the server if necessary.
//
// If enabled, the server is started lazily and the server's random address is reported to Session.SetReplicaAddr.
// If disabled after having been enabled, the server keeps running and ReplicaAddr remains set to its old value.
func (s *ReplicaServer) CheckEnabled() {
	if !s.Session.ForceReplica() && !s.Flashlight.Client().FeatureEnabled(config.FeatureReplica, common.ApplicationVersion) {
		// Replica is not enabled
		log.Debug("Replica not enabled")
		return
	}

	log.Debug("Replica enabled")
	s.startOnce.Do(func() {
		log.Debug("Starting Replica server")
		h, err := s.newHandler()
		if err != nil {
			log.Errorf(
				"failed to start replica server. Will continue without it. Err: %v", err)
			return
		}

		l, srv, err := NewReplicaServer(h)
		if err != nil {
			log.Errorf(
				"failed to start replica server. Will continue without it. Err: %v", err)
			return
		}
		go srv.Serve(l)
		addr := l.Addr().String()
		log.Debugf("Replica started at address: %v", addr)

		// We need to use localhost instead of 127.0.0.1 as the address. If we don't, ExoPlayer on
		// newer versions of Android (9.0 or newer) will fail to load media with the below error:
		//
		// "Cleartext HTTP traffic to 127.0.0.1 not permitted"
		//
		// The ExoPlayer documentation points to some Android network security configuration specifics,
		// see https://exoplayer.dev/troubleshooting.html#fixing-cleartext-http-traffic-not-permitted-errors.
		//
		// However, if we use "localhost" instead of an IP address, the problem goes away.
		_, port, _ := net.SplitHostPort(addr)
		s.Session.SetReplicaAddr(fmt.Sprintf("localhost:%s", port))
	})
}

// NewReplicaServer uses 'handler' to setup a new net.Listener for Replica
// on localhost over the next available TCP port.
//
// Returns an http.Server configured with a Replica http.Handler and a TCP
// listener bound to a random port
func NewReplicaServer(handler *replicaServer.HttpHandler) (net.Listener, *http.Server, error) {
	r := mux.NewRouter()
	r.PathPrefix("/replica").HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.StripPrefix("/replica", handler).ServeHTTP(w, r)
	})
	// Listen on a random TCP port
	l, err := net.Listen("tcp", "localhost:0")
	if err != nil {
		return nil, nil, log.Errorf("replica net.Listen: %v")
	}
	srv := &http.Server{
		Handler: r,
		// Serve over localhost, not for all interfaces, since we don't want
		// the device to broadcast a Replica server
		Addr:              "localhost:" + strconv.Itoa(l.Addr().(*net.TCPAddr).Port),
		ReadHeaderTimeout: 15 * time.Second,
	}
	return l, srv, nil
}

// newHandler constructs a replicaServer.HttpHandler.
func (s *ReplicaServer) newHandler() (*replicaServer.HttpHandler, error) {
	if s.Flashlight == nil {
		return nil, log.Errorf("Flashlight is nil")
	}
	if s.Session == nil {
		return nil, log.Errorf("Session is nil")
	}
	if s.UserConfig == nil {
		return nil, log.Errorf("UserConfig is nil")
	}

	log.Debugf("Starting replica with configDir [%v] and userConfig [%+v]\n", s.ConfigDir, s.UserConfig)
	optsFunc := replicaConfig.NewReplicaOptionsGetter(
		func(options replicaConfig.FeatureOptions) error {
			return s.Flashlight.Client().FeatureOptions(config.FeatureReplica, options)
		},
		s.Session.GetCountryCode,
		geolookup.Refresh)

	input := replicaServer.NewHttpHandlerInput{}
	input.SetDefaults()
	// XXX <30-11-21, soltzen> Since this is mobile, disable seeding and makes
	// the dht node passive
	input.ReadOnlyNode = true
	input.RootUploadsDir = s.ConfigDir
	// XXX <16-12-21, soltzen> Those three flags make sure that uploads are not
	// saved to the torrent client, saved locally, or have any metadata
	// generated for them. This decision is only for lantern-client to protect
	// the privacy of uploaders
	input.AddUploadsToTorrentClient = false
	input.StoreUploadsLocally = false
	input.StoreMetainfoFileAndTokenLocally = false
	// TODO: should probably use Android's cache dir here since this stuff presumably is okay to delete
	input.CacheDir = s.ConfigDir
	input.AddCommonHeaders = func(r *http.Request) {
		common.AddCommonNonUserHeaders(s.UserConfig, r)
	}
	input.GlobalConfig = optsFunc
	input.HttpClient.Transport = proxied.ParallelForIdempotent()
	input.ProcessCORSHeaders = common.ProcessCORS
	input.HttpClient = &http.Client{
		Transport: proxied.AsRoundTripper(
			func(req *http.Request) (*http.Response, error) {
				log.Tracef("Replica HTTP client processing request to: %v (%v)", req.Host, req.URL.Host)
				chained, err := proxied.ChainedNonPersistent("")
				if err != nil {
					return nil, log.Errorf("connecting to proxy: %w", err)
				}
				return chained.RoundTrip(req)
			},
		),
	}
	input.TorrentClientHTTPProxy = func(req *http.Request) (*url.URL, error) {
		log.Tracef("Proxying Replica request [%v] through Flashlight...", req.URL.String())
		proxyAddr, ok := client.Addr(40 * time.Second)
		if !ok {
			return nil, log.Error("HTTP Proxy didn't start in time")
		}
		proxyAddrAsStr := proxyAddr.(string)
		proxyURL, err := url.Parse("http://" + proxyAddrAsStr)
		if err != nil {
			return nil, log.Errorf("error parsing local proxy address: %w", err)
		}
		return proxyURL, nil
	}
	input.TorrentClientLookupTrackerIp = func(u *url.URL) ([]net.IP, error) {
		// TODO: this, and the doh implementation, are copied from lantern-desktop, might be good to keep
		// it in a single place (like flashlight).
		//
		// runDoh runs a Dns-over-https request (proxied with
		// httpClient's Transport) and returns the DNS responses (based
		// on 'typ')
		log.Tracef("Running DOH for %v", u.Hostname())

		runDoh := func(typ doh.DnsType) ([]net.IP, error) {
			ctx, cancelFunc := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancelFunc()
			resp, err := doh.MakeDohRequest(ctx, input.HttpClient, doh.DnsDomain(u.Hostname()), typ)
			if err != nil {
				return nil, err
			}
			ips := []net.IP{}
			for _, ans := range resp.Answer {
				ips = append(ips, net.ParseIP(ans.Data))
			}
			return ips, nil
		}

		allIps := []net.IP{}
		ips, err := runDoh(doh.TypeA)
		if err != nil {
			return nil, log.Errorf("doh request A for [%s] %v", u.Hostname(), err)
		}
		allIps = append(allIps, ips...)

		ips, err = runDoh(doh.TypeAAAA)
		if err != nil {
			return nil, log.Errorf("doh request AAAA for [%s] %v", u.Hostname(), err)
		}
		allIps = append(allIps, ips...)

		// fmt.Printf("dohResp for [%s] = %+v\n", u, allIps)
		return allIps, nil
	}

	input.ReplicaServiceClient = replicaService.ServiceClient{
		HttpClient: input.HttpClient,
		ReplicaServiceEndpoint: func() *url.URL {
			return replicaConfig.GetReplicaServiceEndpointUrl(optsFunc())
		},
	}

	input.OnRequestReceived = func(handler string, extraInfo string) {
		s.analyticsSession.EventWithLabel(
			"replica",
			handler,
			extraInfo,
		)
	}

	replicaHandler, err := replicaServer.NewHTTPHandler(input)
	if err != nil {
		return nil, log.Errorf("creating replica http server: %v", err)
	}
	return replicaHandler, nil
}
