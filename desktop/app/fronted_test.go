package app

import (
	"os"
	"path/filepath"
	"time"

	"github.com/getlantern/flashlight/v7/config"
	"github.com/getlantern/flashlight/v7/embeddedconfig"
	"github.com/getlantern/flashlight/v7/geolookup"
	"github.com/getlantern/fronted"
	"github.com/getlantern/yaml"
)

func configureFronted() {
	tempConfigDir, err := os.MkdirTemp("", "tmp_config")
	if err != nil {
		log.Errorf("Unable to create temp config dir: %v", err)
		os.Exit(1)
	}
	defer os.RemoveAll(tempConfigDir)

	cfg := config.NewGlobal()
	err = yaml.Unmarshal(embeddedconfig.Global, cfg)
	if err != nil {
		log.Errorf("Unable to unmarshal embedded global config: %v", err)
		os.Exit(1)
	}
	certs, err := cfg.TrustedCACerts()
	if err != nil {
		log.Errorf("Unable to read trusted certs: %v", err)
	}
	log.Debug(cfg.Client.FrontedProviders())
	fronted.Configure(certs, cfg.Client.FrontedProviders(), config.DefaultFrontedProviderID, filepath.Join(tempConfigDir, "masquerade_cache"))

	// Perform initial geolookup with a high timeout so that we don't later timeout when trying to
	geolookup.GetCountry(5 * time.Second)
}
