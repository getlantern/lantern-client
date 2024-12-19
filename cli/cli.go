// Command cli provides a command-line implementation of the Lantern client. Run this command with
// -h or --help to see all available arguments.
package main

import (
	"context"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/desktop/app"

	"github.com/pterm/pterm"
)

var (
	log = golog.LoggerFor("lantern")
)

type cliClient struct {
	app *app.App
	mu  sync.Mutex
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
	client.mu.Lock()
	defer client.mu.Unlock()
	if client.app != nil {
		pterm.Warning.Println("Lantern is already running")
		return
	}

	// create new instance of Lantern app
	app, err := app.NewApp()
	if err != nil {
		pterm.Error.Printf("Unable to initialize app: %v", err)
		return
	}
	client.app = app

	// Run Lantern in the background
	go app.Run(ctx)
}

func (client *cliClient) stop() {
	client.mu.Lock()
	defer client.mu.Unlock()
	if client.app == nil {
		// Lantern is not running, no cleanup needed
		return
	}

	pterm.Info.Println("Stopping Lantern...")
	client.app.Exit(nil)
	client.app = nil

	// small delay to give Lantern time to cleanup
	time.Sleep(1 * time.Second)
	pterm.Success.Println("Lantern stopped successfully.")
}
