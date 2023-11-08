package app

import (
	"github.com/getlantern/golog"
	"github.com/getlantern/eventual"
	"github.com/getlantern/flashlight/v7"
)

var (
	log                = golog.LoggerFor("lantern-desktop.app")
)

// App is the core of the Lantern desktop application, in the form of a library.
type App struct {
	hasExited   int64
	configDir   string
	exited      eventual.Value
	flashlight  *flashlight.Flashlight
}

// NewApp creates a new desktop app that initializes the app and acts as a moderator between all desktop components.
func NewApp(flags flashlight.Flags, configDir string) *App {
	app := &App{
		configDir: configDir,
		exited: eventual.NewValue(),
	}

	return app
}

// Run starts the app.
func (app *App) Run(isMain bool) {

}

// WaitForExit waits for a request to exit the application.
func (app *App) WaitForExit() error {
	err, _ := app.exited.Get(-1)
	if err == nil {
		return nil
	}
	return err.(error)
}
