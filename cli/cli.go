package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/app"
	"github.com/getlantern/lantern-client/desktop/settings"
	"github.com/getlantern/lantern-client/internalsdk/common"

	"github.com/pterm/pterm"
)

var (
	log = golog.LoggerFor("lantern")
)

type cliClient struct {
	*app.App
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-signalChan
		pterm.Warning.Println("Received shutdown signal.")
		cancel()
	}()

	client := &cliClient{}
	client.start(ctx)
	defer client.stop()

	<-ctx.Done()
}

func (client *cliClient) start(ctx context.Context) {
	if client.App != nil {
		pterm.Warning.Println("Lantern is already running")
		return
	}
	// create new instance of Lantern app
	client.App = app.NewApp()
	// Run Lantern in the background
	client.Run(ctx)
}

func (client *cliClient) stop() {
	if client.App == nil {
		// Lantern is not running, no cleanup needed
		return
	}

	pterm.Info.Println("Stopping Lantern...")
	client.App.Exit(nil)
	client.App = nil

	// small delay to give Lantern time to cleanup
	time.Sleep(1 * time.Second)
	pterm.Success.Println("Lantern stopped successfully.")
}

// TODO: Move to sdk package for easy re-use across platforms
func startStandalone() {
	// Parse CLI arguments
	flags := flashlight.ParseFlags()

	cdir := configDir(&flags)
	pterm.Info.Println("Starting lantern: configDir", cdir)

	httpProxyAddr := "127.0.0.1:0"
	if flags.ForceProxyAddr != "" {
		// Log provided CLI arguments
		pterm.Info.Println("Using http proxy address:", flags.ForceProxyAddr)
		httpProxyAddr = flags.ForceProxyAddr
	}

	// Create user configuration for Lantern
	settings := settings.LoadSettings(cdir)
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

			},
			func(err error) {
				log.Errorf("Lantern error: %v", err)
			},
		)
	}()
	pterm.Info.Println("Lantern is running. Waiting for shutdown signal...")
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
