package main

import (
	"context"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"syscall"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/common"

	"github.com/pterm/pterm"
)

var (
	// lanternClient holds the reference to the running Lantern client instance
	lanternClient *client.Client
	mu            sync.Mutex
	log           = golog.LoggerFor("lantern")
)

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	// Parse CLI arguments
	flags := flashlight.ParseFlags()

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-signalChan
		pterm.Warning.Println("Received shutdown signal.")
		cancel()
	}()

	// Start Lantern
	startLantern(flags)
	defer stopLantern()
	<-ctx.Done()
}

func startLantern(flags flashlight.Flags) {
	cdir := configDir(&flags)
	pterm.Info.Println("Starting lantern: configDir", cdir)

	httpProxyAddr := "127.0.0.1:0"
	// Log provided CLI arguments
	if flags.ForceProxyAddr != "" {
		pterm.Info.Println("Using http proxy address:", flags.ForceProxyAddr)
		httpProxyAddr = flags.ForceProxyAddr
	}

	// Create user configuration for Lantern
	settings := loadSettings(cdir)
	userConfig := common.NewUserConfig(common.DefaultAppName, settings.GetDeviceID(), settings.GetUserID(),
		settings.GetToken(), map[string]string{}, settings.GetLanguage())

	// Initialize the Lantern runner
	runner, err := flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		cdir, // place to store lantern configuration
		false,
		func() bool { return false }, // always connected
		func() bool { return true },
		func() bool { return false }, // do not proxy private hosts on Android
		func() bool { return true },  // auto report
		flags.AsMap(),
		userConfig,
		stats.NewTracker(),
		func() bool { return false },
		func() string { return "" }, // only used for desktop
		nil,
		func(category, action, label string) {},
	)
	if err != nil {
		log.Fatalf("failed to start flashlight: %v", err)
	}
	// Run Lantern in the background
	go func() {
		runner.Run(
			httpProxyAddr, // listen for HTTP on provided address
			"127.0.0.1:0", // listen for SOCKS on random address
			func(c *client.Client) {
				mu.Lock()
				lanternClient = c
				mu.Unlock()
			},
			func(err error) {
				log.Errorf("Lantern error: %v", err)
			},
		)
	}()
	pterm.Info.Println("Lantern is running. Waiting for shutdown signal...")
}

func stopLantern() {
	mu.Lock()
	defer mu.Unlock()

	if lanternClient == nil {
		// Lantern is not running, no cleanup needed
		return
	}

	pterm.Info.Println("Stopping Lantern...")
	if err := lanternClient.Stop(); err != nil {
		pterm.Error.Println("Failed to stop Lantern:", err)
		return
	}
	lanternClient = nil
	// small delay to give Lantern time to cleanup
	time.Sleep(1 * time.Second)
	pterm.Success.Println("Lantern stopped successfully.")
}

// loadSettings loads the initial settings at startup, either from disk or using defaults.
func loadSettings(configDir string) *settings.Settings {
	path := filepath.Join(configDir, "settings.yaml")
	return settings.LoadSettingsFrom(common.ApplicationVersion, common.RevisionDate, common.BuildDate, path)
}

func configDir(flags *flashlight.Flags) string {
	cdir := flags.ConfigDir
	if cdir == "" {
		cdir = appdir.General(common.DefaultAppName)
	}
	log.Debugf("Using config dir %v", cdir)
	if _, err := os.Stat(cdir); err != nil {
		if os.IsNotExist(err) {
			// Create config dir
			if err := os.MkdirAll(cdir, 0750); err != nil {
				log.Errorf("Unable to create configdir at %s: %s", configDir, err)
			}
		}
	}
	return cdir
}
