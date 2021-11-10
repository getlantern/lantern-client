package internalsdk

import (
	"net"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"github.com/getlantern/flashlight/config"
	"github.com/getlantern/flashlight/proxied"
	replicaServer "github.com/getlantern/replica/server"
	replicaService "github.com/getlantern/replica/service"
	"github.com/gorilla/mux"
)

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
		Addr:         "localhost:" + strconv.Itoa(l.Addr().(*net.TCPAddr).Port),
		WriteTimeout: 15 * time.Second,
		ReadTimeout:  15 * time.Second,
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
	input.RootUploadsDir = configDir
	input.CacheDir = configDir
	input.UserConfig = userConfig
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
			// TODO <08-10-21, soltzen> Maybe make this modifiable like lantern-desktop?
			// Ref: https://github.com/getlantern/lantern-desktop/blob/778f6e600433d0cf6349c04e9738c0673758d76e/desktop/app.go#L587
			return &url.URL{
				Scheme: "https",
				Host:   "replica-search.lantern.io",
			}
		},
	}
	input.GlobalConfig = optsFunc
	replicaHandler, err := replicaServer.NewHTTPHandler(input)
	if err != nil {
		return nil, log.Errorf("creating replica http server: %v", err)
	}
	return replicaHandler, nil
}
