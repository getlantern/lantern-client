package ios

import (
	"bytes"
	"compress/gzip"
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httputil"
	"os"
	"path/filepath"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/yaml"

	commonconfig "github.com/getlantern/common/config"
	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/email"
	"github.com/getlantern/flashlight/v7/embeddedconfig"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/flashlight/v7/proxied"

	"context"

	"github.com/getlantern/lantern-client/internalsdk/common"
)

const (
	userConfigYaml = "userconfig.yaml"
	globalYaml     = "global.yaml"
	proxiesYaml    = "proxies.yaml"
)

// ConfigResult captures the result of calling Configure()
type ConfigResult struct {
	// VPNNeedsReconfiguring indicates that something in the config changed and
	// that the VPN needs to be reconfigured.
	VPNNeedsReconfiguring bool

	// IPSToExcludeFromVPN lists all IPS that should be excluded from the VPNS's
	// routes in a comma-delimited string
	IPSToExcludeFromVPN string
}

type configurer struct {
	configFolderPath string
	hardcodedProxies string
	uc               *UserConfig
	rt               http.RoundTripper
}

type Configurer interface {
	Configure(userID int, proToken string, refreshProxies bool) (*ConfigResult, error)
	OpenGlobal() (*config.Global, string, bool, error)
	HasGlobalConfig() bool
}

// Configure fetches updated configuration from the cloud and stores it in
// configFolderPath. There are 5 files that must be initialized in
// configFolderPath - global.yaml, global.yaml.etag, proxies.yaml,
// proxies.yaml.etag and masquerade_cache. deviceID should be a string that
// uniquely identifies the current device. hardcodedProxies allows manually specifying
// a proxies.yaml configuration that overrides whatever we fetch from the cloud.
func Configure(configFolderPath string, userID int, proToken, deviceID string, refreshProxies bool, hardcodedProxies string) (*ConfigResult, error) {
	log.Debugf("Configuring client for device '%v' at config path '%v' userid '%v' token '%v'", deviceID, configFolderPath, userID, proToken)
	defer log.Debug("Finished configuring client")
	uc := userConfigFor(userID, proToken, deviceID)
	cf := &configurer{
		configFolderPath: configFolderPath,
		hardcodedProxies: hardcodedProxies,
		uc:               uc,
		rt:               proxied.ParallelPreferChained(),
	}
	return cf.Configure(userID, proToken, refreshProxies)
}

// NewConfigurer returns a new instance of Configurer
func NewConfigurer(configFolderPath string, userID int, proToken, deviceID, hardcodedProxies string) Configurer {
	return &configurer{
		configFolderPath: configFolderPath,
		hardcodedProxies: hardcodedProxies,
		uc:               userConfigFor(userID, proToken, deviceID),
	}
}

type UserConfig struct {
	common.UserConfigData
	Country     string
	AllowProbes bool
}

// Important:
// This method is responsible for potentially delaying the UI startup process.
// Occasionally, the execution time of this method varies significantly, sometimes completing within 5 seconds, while other times taking more than 30 seconds.
// For instance, examples from my running
// config.go:167 Configured completed in 35.8970435s
// config.go:167 Configured completed in 4.0234035s
// config.go:176 Configured completed in 3.700574125s

// TODO: Implement a timeout mechanism to handle prolonged execution times and potentially execute this method in the background to maintain smooth UI startup performance.
func (cf *configurer) Configure(userID int, proToken string, refreshProxies bool) (*ConfigResult, error) {
	// Log the full method run time.
	defer func(start time.Time) {
		log.Debugf("Configured completed in %v", time.Since(start))
	}(time.Now())
	result := &ConfigResult{}
	if err := cf.writeUserConfig(); err != nil {
		return nil, err
	}

	global, globalEtag, globalInitialized, err := cf.OpenGlobal()
	if err != nil {
		return nil, err
	}

	proxies, proxiesEtag, proxiesInitialized, err := cf.openProxies()
	if err != nil {
		return nil, err
	}

	result.VPNNeedsReconfiguring = globalInitialized || proxiesInitialized

	var globalUpdated, proxiesUpdated bool

	setupFronting := func() error {
		log.Debug("Setting up fronting")
		defer log.Debug("Set up fronting")
		if frontingErr := cf.configureFronting(global, shortFrontedAvailableTimeout); frontingErr != nil {
			log.Errorf("Unable to configure fronting on first try, update global config directly from GitHub and try again: %v", frontingErr)
			global, globalUpdated = cf.updateGlobal(http.DefaultTransport, global, globalEtag, "https://raw.githubusercontent.com/getlantern/lantern-binaries/main/cloud.yaml.gz")
			return cf.configureFronting(global, longFrontedAvailableTimeout)
		}
		return nil
	}

	if frontingErr := setupFronting(); frontingErr != nil {
		log.Errorf("Unable to configure fronting, sticking with embedded configuration: %v", err)
	} else {
		log.Debug("Refreshing geolookup")

		go func() {
			cf.uc.Country = geolookup.GetCountry(1 * time.Minute)
			log.Debugf("Successful geolookup: country %s", cf.uc.Country)
			cf.uc.AllowProbes = global.FeatureEnabled(
				config.FeatureProbeProxies,
				common.Platform,
				cf.uc.AppName,
				"",
				int64(cf.uc.UserID),
				cf.uc.Token != "",
				cf.uc.Country)
			log.Debugf("Allow probes?: %v", cf.uc.AllowProbes)
			if err := cf.writeUserConfig(); err != nil {
				log.Errorf("Unable to save updated UserConfig with country and allow probes: %v", err)
			}
		}()

		log.Debug("Updating global config")
		global, globalUpdated = cf.updateGlobal(cf.rt, global, globalEtag, "https://globalconfig.flashlightproxy.com/global.yaml.gz")
		log.Debug("Updated global config")
		if refreshProxies {
			log.Debug("Refreshing proxies")
			proxies, proxiesUpdated = cf.updateProxies(proxies, proxiesEtag)
			log.Debug("Refreshed proxies")
		}

		result.VPNNeedsReconfiguring = result.VPNNeedsReconfiguring || globalUpdated || proxiesUpdated
	}

	for _, provider := range global.Client.Fronted.Providers {
		for _, masquerade := range provider.Masquerades {
			if len(result.IPSToExcludeFromVPN) == 0 {
				result.IPSToExcludeFromVPN = masquerade.IpAddress
			} else {
				result.IPSToExcludeFromVPN = fmt.Sprintf("%v,%v", result.IPSToExcludeFromVPN, masquerade.IpAddress)
			}
		}
	}

	for _, proxy := range proxies {
		if proxy.Addr != "" {
			host, _, _ := net.SplitHostPort(proxy.Addr)
			result.IPSToExcludeFromVPN = fmt.Sprintf("%v,%v", host, result.IPSToExcludeFromVPN)
			log.Debugf("Added %v", host)
		}
		if proxy.MultiplexedAddr != "" {
			host, _, _ := net.SplitHostPort(proxy.MultiplexedAddr)
			result.IPSToExcludeFromVPN = fmt.Sprintf("%v,%v", host, result.IPSToExcludeFromVPN)
			log.Debugf("Added %v", host)
		}
	}

	email.SetDefaultRecipient(global.ReportIssueEmail)

	return result, nil
}

func (cf *configurer) writeUserConfig() error {
	bytes, err := yaml.Marshal(cf.uc)
	if err != nil {
		return errors.New("Unable to marshal user config: %v", err)
	}
	if writeErr := os.WriteFile(cf.fullPathTo(userConfigYaml), bytes, 0644); writeErr != nil {
		return errors.New("Unable to save userconfig.yaml: %v", err)
	}
	return nil
}

func (cf *configurer) readUserConfig() (*UserConfig, error) {
	bytes, err := os.ReadFile(cf.fullPathTo(userConfigYaml))
	if err != nil {
		return nil, errors.New("Unable to read userconfig.yaml: %v", err)
	}
	if len(bytes) == 0 {
		return nil, errors.New("Empty userconfig.yaml")
	}
	uc := &UserConfig{}
	if parseErr := yaml.Unmarshal(bytes, uc); parseErr != nil {
		return nil, errors.New("Unable to parse userconfig.yaml: %v", err)
	}
	return uc, nil
}

func (cf *configurer) OpenGlobal() (*config.Global, string, bool, error) {
	cfg := &config.Global{}
	etag, updated, err := cf.openConfig(globalYaml, cfg, embeddedconfig.Global)
	return cfg, etag, updated, err
}

func (cf *configurer) HasGlobalConfig() bool {
	_, err := os.Stat(cf.fullPathTo(globalYaml))
	return err == nil
}

func (cf *configurer) openProxies() (map[string]*commonconfig.ProxyConfig, string, bool, error) {
	cfg := make(map[string]*commonconfig.ProxyConfig)
	etag, updated, err := cf.openConfig(proxiesYaml, cfg, embeddedconfig.Proxies)
	return cfg, etag, updated, err
}

func (cf *configurer) updateFromHardcodedProxies() ([]byte, string, error) {
	return []byte(cf.hardcodedProxies), "hardcoded", nil
}

func (cf *configurer) openConfig(name string, cfg interface{}, embedded []byte) (string, bool, error) {
	var initialized bool
	configFile := cf.fullPathTo(name)
	log.Debugf("Opening config file at %s", configFile)
	bytes, err := os.ReadFile(configFile)
	if err == nil && len(bytes) > 0 {
		log.Debugf("Loaded %v from file", name)
	} else {
		log.Debugf("Initializing %v from embedded", name)
		bytes = embedded
		initialized = true
		if writeErr := os.WriteFile(configFile, bytes, 0644); writeErr != nil {
			return "", false, errors.New("Unable to write embedded %v to disk: %v", name, writeErr)
		}
	}
	if parseErr := yaml.Unmarshal(bytes, cfg); parseErr != nil {
		return "", false, errors.New("Unable to parse %v: %v", name, parseErr)
	}
	etagBytes, err := os.ReadFile(cf.fullPathTo(name + ".etag"))
	if err != nil {
		log.Debugf("No known etag for %v", name)
		etagBytes = []byte{}
	}
	return string(etagBytes), initialized, nil
}

func (cf *configurer) updateGlobal(rt http.RoundTripper, cfg *config.Global, etag string, url string) (*config.Global, bool) {
	updated := &config.Global{}
	didFetch, err := cf.updateFromWeb(rt, globalYaml, etag, updated, url)
	if err != nil {
		log.Error(err)
	}
	if didFetch {
		cfg = updated
	}
	return cfg, didFetch
}

func (cf *configurer) updateProxies(cfg map[string]*commonconfig.ProxyConfig, etag string) (map[string]*commonconfig.ProxyConfig, bool) {
	updated := make(map[string]*commonconfig.ProxyConfig)
	didFetch, err := cf.updateFromWeb(cf.rt, proxiesYaml, etag, updated, "http://config.getiantem.org/proxies.yaml.gz")
	if err != nil {
		log.Error(err)
	}
	if len(updated) == 0 {
		log.Error("Proxies returned by config server was empty, ignoring")
		didFetch = false
	}
	if didFetch {
		cfg = updated
	}
	return cfg, didFetch
}

func (cf *configurer) updateFromWeb(rt http.RoundTripper, name string, etag string, cfg interface{}, url string) (bool, error) {
	var bytes []byte
	var newETag string
	var err error

	if name == proxiesYaml && cf.hardcodedProxies != "" {
		bytes, newETag, err = cf.updateFromHardcodedProxies()
	} else {
		bytes, newETag, err = cf.doUpdateFromWeb(rt, name, etag, cfg, url)
	}
	if err != nil {
		return false, err
	}

	if bytes == nil {
		// config unchanged
		return false, nil
	}

	cf.saveConfig(name, bytes)
	cf.saveEtag(name, newETag)

	if name == proxiesYaml {
		log.Debugf("Updated proxies.yaml from cloud:\n%v", string(bytes))
	} else {
		log.Debugf("Updated %v from cloud", name)
	}

	return newETag != etag, nil
}

func (cf *configurer) doUpdateFromWeb(rt http.RoundTripper, name string, etag string, cfg interface{}, url string) ([]byte, string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 40*time.Second)
	defer cancel()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, "", errors.New("Unable to construct request to fetch %v from %v: %v", name, url, err)
	}

	if etag != "" {
		req.Header.Set(common.IfNoneMatchHeader, etag)
	}
	req.Header.Set("Accept", "application/x-gzip")
	// Prevents intermediate nodes (domain-fronters) from caching the content
	req.Header.Set("Cache-Control", "no-cache")
	common.AddCommonHeaders(cf.uc, req)

	// make sure to close the connection after reading the Body
	// this prevents the occasional EOFs errors we're seeing with
	// successive requests
	req.Close = true

	resp, err := rt.RoundTrip(req)
	if err != nil {
		return nil, "", errors.New("Unable to fetch cloud config at %s: %s", url, err)
	}
	dump, dumperr := httputil.DumpResponse(resp, false)
	if dumperr != nil {
		log.Errorf("Could not dump response: %v", dumperr)
	} else {
		log.Debugf("Response headers from %v:\n%v", url, string(dump))
	}
	defer func() {
		if closeerr := resp.Body.Close(); closeerr != nil {
			log.Errorf("Error closing response body: %v", closeerr)
		}
	}()

	if resp.StatusCode == 304 {
		log.Debugf("%v unchanged in cloud", name)
		return nil, "", nil
	} else if resp.StatusCode != 200 {
		if dumperr != nil {
			return nil, "", errors.New("Bad config response code for %v: %v", name, resp.StatusCode)
		}
		return nil, "", errors.New("Bad config resp for %v:\n%v", name, string(dump))
	}

	newEtag := resp.Header.Get(common.EtagHeader)
	buf := &bytes.Buffer{}
	body := io.TeeReader(resp.Body, buf)
	gzReader, err := gzip.NewReader(body)
	if err != nil {
		return nil, "", errors.New("Unable to open gzip reader: %s", err)
	}

	defer func() {
		if err := gzReader.Close(); err != nil {
			log.Errorf("Unable to close gzip reader: %v", err)
		}
	}()

	bytes, err := io.ReadAll(gzReader)
	if err != nil {
		return nil, "", errors.New("Unable to read response for %v: %v", name, err)
	}

	if parseErr := yaml.Unmarshal(bytes, cfg); parseErr != nil {
		return nil, "", errors.New("Unable to parse update for %v: %v", name, parseErr)
	}

	if newEtag == "" {
		sum := md5.Sum(buf.Bytes())
		newEtag = hex.EncodeToString(sum[:])
	}

	return bytes, newEtag, nil
}

func (cf *configurer) configureFronting(global *config.Global, timeout time.Duration) error {
	log.Debug("Configuring fronting")
	certs, err := global.TrustedCACerts()
	if err != nil {
		return errors.New("Unable to read trusted CAs from global config, can't configure domain fronting: %v", err)
	}

	proxied.OnNewFronts(certs, global.Client.FrontedProviders())

	log.Debug("Configured fronting")
	return nil
}

func (cf *configurer) saveConfig(name string, bytes []byte) {
	err := os.WriteFile(cf.fullPathTo(name), bytes, 0644)
	if err != nil {
		log.Errorf("Unable to save config for %v: %v", name, err)
	}
}

func (cf *configurer) saveEtag(name string, etag string) {
	err := os.WriteFile(cf.fullPathTo(name+".etag"), []byte(etag), 0644)
	if err != nil {
		log.Errorf("Unable to save etag for %v: %v", name, err)
	}
}

func (cf *configurer) fullPathTo(filename string) string {
	return filepath.Join(cf.configFolderPath, filename)
}
