package internalsdk

import (
	"net"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"github.com/getlantern/flashlight"
	"github.com/getlantern/flashlight/common"
	"github.com/getlantern/flashlight/config"
	"github.com/getlantern/flashlight/geolookup"
	"github.com/getlantern/flashlight/ops"
	"github.com/getlantern/flashlight/proxied"
	replicaServer "github.com/getlantern/replica/server"
	replicaService "github.com/getlantern/replica/service"
	"github.com/gorilla/mux"
)

// Same as from mobilesdk/Settings.java
const (
	REPLICAENABLED_YES           = iota
	REPLICAENABLED_NO            = iota
	REPLICAENABLED_GLOBAL_CONFIG = iota
)

// See the 'Enabling Replica' section in the README for more info on the
// decision tree here
func shouldRunReplica(settings Settings, flashlightInst *flashlight.Flashlight) bool {
	switch settings.GetReplicaEnabledState() {
	case REPLICAENABLED_YES:
		log.Debugf("shouldRunReplica: returning true regardless of global config")
		return true
	case REPLICAENABLED_NO:
		log.Debugf("shouldRunReplica: returning false regardless of global config")
		return false
	case REPLICAENABLED_GLOBAL_CONFIG:
		features := flashlightInst.EnabledFeatures()
		log.Debugf("All enabled features for country [%+v]: %+v", geolookup.GetCountry(5*time.Second), features)
		_, ok := features[config.FeatureReplica]
		log.Debugf("shouldRunReplica: returning %v", ok)
		return ok
	default:
		panic(log.Errorf("Unknown option for GetReplicaEnabledState(). This should never happen"))
	}
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
	r.Handle("/", r)
	// Listen on a random TCP port
	l, err := net.Listen("tcp", ":0")
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

// newReplicaHttpHandler constructs a replicaServer.HttpHandler.
// This function will lazily fetch information from the global yaml config
// using 'fetchFeatureOptionsFunc' function.
func newReplicaHttpHandler(
	configDir string,
	userConfig *userConfig,
	// function to lazily fetch config.FeatureOptions for Replica from Flashlight
	fetchFeatureOptionsFunc func(string, config.FeatureOptions) error,
) (*replicaServer.HttpHandler, error) {
	if userConfig == nil {
		panic(log.Errorf("userConfig is nil"))
	}
	if fetchFeatureOptionsFunc == nil {
		panic(log.Errorf("featureOptionsFunc is nil"))
	}

	log.Debugf("Starting replica with configDir [%v] and userConfig [%+v]\n", configDir, userConfig)
	optsFunc := func() *config.ReplicaOptions {
		var opts config.ReplicaOptions
		if err := fetchFeatureOptionsFunc(config.FeatureReplica, &opts); err != nil {
			log.Errorf("Could not fetch replica feature options: %v", err)
			return nil
		}
		return &opts
	}

	input := replicaServer.NewHttpHandlerInput{}
	input.SetDefaults()
	// XXX <30-11-21, soltzen> Since this is mobile, disable seeding and makes
	// the dht node passive
	input.ReadOnlyNode = true
	input.RootUploadsDir = configDir
	// XXX <16-12-21, soltzen> Those three flags make sure that uploads are not
	// saved to the torrent client, saved locally, or have any metadata
	// generated for them. This decision is only for android-lantern to protect
	// the privacy of uploaders
	input.AddUploadsToTorrentClient = false
	input.StoreUploadsLocally = false
	input.StoreMetainfoFileAndTokenLocally = false
	input.CacheDir = configDir
	input.AddCommonHeaders = func(r *http.Request) {
		common.AddCommonHeaders(userConfig, r)
	}
	input.GlobalConfig = func() replicaServer.ReplicaOptions {
		return optsFunc()
	}
	input.ProxiedRoundTripper = proxied.ParallelForIdempotent()
	input.ProcessCORSHeaders = common.ProcessCORS
	input.InstrumentResponseWriter = func(w http.ResponseWriter,
		label string) replicaServer.InstrumentedResponseWriter {
		return ops.InitInstrumentedResponseWriter(w, label)
	}
	input.HttpClient = &http.Client{
		Transport: proxied.AsRoundTripper(
			func(req *http.Request) (*http.Response, error) {
				chained, err := proxied.ChainedNonPersistent("")
				if err != nil {
					return nil, log.Errorf("connecting to proxy: %w", err)
				}
				return chained.RoundTrip(req)
			},
		),
	}

	input.ReplicaServiceClient = replicaService.ServiceClient{
		HttpClient: input.HttpClient,
		ReplicaServiceEndpoint: func() *url.URL {
			// Fetch options
			opts := optsFunc()
			if opts == nil {
				log.Errorf("ReplicaOptions is not ready yet: triggering geolookup.Refresh() and using default endpoint: %v",
					replicaService.GlobalChinaDefaultServiceUrl)
				geolookup.Refresh()
				return replicaService.GlobalChinaDefaultServiceUrl
			}

			// Fetch country: if country wasn't fetch-able, use the default endpoint
			raw := opts.ReplicaRustDefaultEndpoint
			country := userConfig.session.GetCountryCode()
			if country == "" {
				log.Errorf("Failed to fetch country while configuring new replica-rust endpoint: re-running geolookup and defaulting to %q", opts.ReplicaRustDefaultEndpoint)
				geolookup.Refresh()
			}
			if countryRaw := opts.ReplicaRustEndpoints[country]; countryRaw != "" {
				raw = countryRaw
			} else {
				log.Debugf("No custom replica endpoint for %v. Using default one: %v", country, raw)
			}

			// Parse endpoint
			url, err := url.Parse(raw)
			if err != nil {
				log.Errorf("Could not parse replica rust URL %v", err)
				return replicaService.GlobalChinaDefaultServiceUrl
			}
			log.Debugf("parsed new endpoint for country %s successfully: %v", country, url.String())
			return url
		},
	}
	input.GlobalConfig = func() replicaServer.ReplicaOptions {
		return optsFunc()
	}
	replicaHandler, err := replicaServer.NewHTTPHandler(input)
	if err != nil {
		return nil, log.Errorf("creating replica http server: %v", err)
	}
	return replicaHandler, nil
}
