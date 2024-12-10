package main

import (
	"context"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/alexflint/go-arg"
	"github.com/getlantern/golog"

	"github.com/getlantern/appdir"
	"github.com/getlantern/flashlight/v7"
	"github.com/getlantern/flashlight/v7/client"
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/pterm/pterm"
)

var (
	lanternClient *client.Client
	mu            sync.Mutex
	log           = golog.LoggerFor("lantern")
)

type args struct {
	HttpProxyAddress  string `arg:"--http-proxy" help:"The HTTP proxy address to use" default:":0"`
	SocksProxyAddress string `arg:"--socks-proxy" help:"The SOCKS proxy address to use" default:":0"`
	StickyConfig      bool   `arg:"--sticky-config" help:"Whether to use sticky config" default:"false"`
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	var args args
	arg.MustParse(&args)

	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-signalChan
		pterm.Warning.Println("Received shutdown signal.")
		cancel()
	}()

	startLantern(args)
	defer stopLantern()
	<-ctx.Done()
}

func startLantern(args args) {
	configDir := appdir.General(common.DefaultAppName)
	pterm.Info.Println("Starting lantern: configDir %s", configDir)

	if args.HttpProxyAddress != "" {
		pterm.Info.Println("Using http proxy address:", args.HttpProxyAddress)
	}
	if args.SocksProxyAddress != "" {
		pterm.Info.Println("Using socks proxy address:", args.SocksProxyAddress)
	}
	if args.StickyConfig {
		pterm.Info.Println("Using sticky config...")
	}

	userConfig := common.NewUserConfig("", "a34113", 3456344, "tok123", map[string]string{}, "")

	runner, err := flashlight.New(
		common.DefaultAppName,
		common.ApplicationVersion,
		common.RevisionDate,
		configDir, // place to store lantern configuration
		false,
		func() bool { return false }, // always connected
		func() bool { return true },
		func() bool { return false }, // do not proxy private hosts on Android
		func() bool { return true },  // auto report
		map[string]interface{}{},
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
	go func() {
		runner.Run(
			args.HttpProxyAddress,  // listen for HTTP on provided address
			args.SocksProxyAddress, // listen for SOCKS on random address
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
