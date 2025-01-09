package geolookup

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/getlantern/eventual/v2"
	geo "github.com/getlantern/geolookup"
	"github.com/getlantern/golog"

	"github.com/getlantern/flashlight/v7/ops"
	"github.com/getlantern/flashlight/v7/proxied"
)

var (
	log = golog.LoggerFor("ios.geolookup")

	refreshRequest = make(chan interface{}, 1)
	currentGeoInfo = eventual.NewValue()
	watchers       []chan bool
	persistToFile  string
	mx             sync.Mutex
	roundTripper   http.RoundTripper
)

const (
	maxTimeout      = 10 * time.Minute
	retryWaitMillis = 100
	maxRetryWait    = 30 * time.Second
)

type GeoInfo struct {
	IP       string
	City     *geo.City
	FromDisk bool
}

func init() {
	SetDefaultRoundTripper()
}

// GetIP gets the IP. If the IP hasn't been determined yet, waits up to the
// given timeout for an IP to become available.
func GetIP(timeout time.Duration) string {
	gi, err := GetGeoInfo(timeout)
	if err != nil {
		log.Debugf("Could not get IP: %v", err)
		return ""
	}
	return gi.IP
}

// GetCountry gets the country. If the country hasn't been determined yet, waits
// up to the given timeout for a country to become available.
func GetCountry(timeout time.Duration) string {
	gi, err := GetGeoInfo(timeout)
	if err != nil {
		log.Debugf("Could not get country: %v", err)
		return ""
	}
	return gi.City.Country.IsoCode
}

func GetGeoInfo(timeout time.Duration) (*GeoInfo, error) {
	// We need to specially handle negative timeouts because some callers may use
	// eventual.Forever (aka -1), expecting it to block forever.
	if timeout < 0 {
		timeout = maxTimeout
	}
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()

	gi, err := currentGeoInfo.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf(
			"could not get geoinfo with timeout %v: %w",
			timeout,
			err,
		)
	}
	if gi == nil {
		return nil, fmt.Errorf("no geo info after %v", timeout)
	}
	return gi.(*GeoInfo), nil
}

// EnablePersistence enables persistence of the current geo info to disk at the named file and
// initializes current geo info from that file if necessary.
func EnablePersistence(geoFile string) {
	mx.Lock()
	defer mx.Unlock()

	// use this file going forward
	persistToFile = geoFile

	log.Debugf("Will persist geolocation info to %v", persistToFile)

	// initialize from file if necessary
	knownCountry := GetCountry(0)
	if knownCountry == "" {
		file, err := os.Open(persistToFile)
		if err == nil {
			log.Debugf("Initializing geolocation info from %v", persistToFile)
			dec := json.NewDecoder(file)
			gi := &GeoInfo{
				FromDisk: true,
			}
			decodeErr := dec.Decode(gi)
			if decodeErr != nil {
				log.Errorf(
					"Error initializing geolocation info from %v: %v",
					persistToFile,
					decodeErr,
				)
				return
			}
			setGeoInfo(gi, false)
		}
	}
}

// Refresh refreshes the geolookup information by calling the remote geolookup
// service. It will keep calling the service until it's able to determine an IP
// and country.
func Refresh() {
	select {
	case refreshRequest <- true:
		log.Debug("Requested refresh")
	default:
		log.Debug("Refresh already in progress")
	}
}

// OnRefresh creates a channel that caller can receive on when new geolocation
// information is got.
func OnRefresh() <-chan bool {
	ch := make(chan bool, 1)
	mx.Lock()
	watchers = append(watchers, ch)
	mx.Unlock()
	return ch
}

func init() {
	go run()
}

func run() {
	for range refreshRequest {
		log.Debug("Refreshing geolocation info")
		geoInfo := lookup()

		// Check if the IP has changed and if the old IP is simply cached from
		// disk. If it is cached, we should still notify anyone looking for
		// a new IP because they won't have been notified of the IP on disk,
		// as that is loaded very soon on startup.
		if !isNew(geoInfo) {
			log.Debug("public IP from network did not change - not notifying watchers")
			continue
		}
		log.Debug("Setting new geolocation info")
		mx.Lock()
		setGeoInfo(geoInfo, true)
		mx.Unlock()
	}
}

func isNew(newGeoInfo *GeoInfo) bool {
	if newGeoInfo == nil {
		return false
	}
	oldGeoInfo, err := GetGeoInfo(0)
	if err != nil {
		return true
	}
	if oldGeoInfo == nil {
		return true
	}
	return oldGeoInfo.IP != newGeoInfo.IP ||
		oldGeoInfo.FromDisk != newGeoInfo.FromDisk
}

func setGeoInfo(gi *GeoInfo, persist bool) {
	currentGeoInfo.Set(gi)
	w := watchers
	for _, ch := range w {
		select {
		case ch <- true:
		default:
		}
	}
	if persist && persistToFile != "" {
		b, err := json.Marshal(gi)
		if err != nil {
			log.Errorf(
				"Unable to marshal geolocation info to JSON for persisting: %v",
				err,
			)
			return
		}
		writeErr := os.WriteFile(persistToFile, b, 0644)
		if writeErr != nil {
			log.Errorf(
				"Error persisting geolocation info to %v: %v",
				persistToFile,
				err,
			)
		}
	}
}

func lookup() *GeoInfo {
	consecutiveFailures := 0

	for {
		gi, err := doLookup()
		if err == nil {
			return gi
		}
		log.Debugf("Unable to get current location: %s", err)
		wait := time.Duration(
			math.Pow(
				2,
				float64(consecutiveFailures),
			)*float64(
				retryWaitMillis,
			),
		) * time.Millisecond
		if wait > maxRetryWait {
			wait = maxRetryWait
		}
		log.Debugf("Waiting %v before retrying", wait)
		time.Sleep(wait)
		consecutiveFailures++
	}
}

func doLookup() (*GeoInfo, error) {
	op := ops.Begin("geolookup")
	defer op.End()
	city, ip, err := geo.LookupIP("", roundTripper)

	if err != nil {
		log.Errorf("Could not lookup IP %v", err)
		return nil, op.FailIf(err)
	}
	return &GeoInfo{
			IP:       ip,
			City:     city,
			FromDisk: false},
		nil
}

func SetDefaultRoundTripper() {
	roundTripper = proxied.ParallelPreferChained()
}
