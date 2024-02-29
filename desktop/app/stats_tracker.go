package app

import (
	"github.com/getlantern/flashlight/v7/stats"
)

type statsTracker struct {
	stats.Tracker
	app *App
}

func NewStatsTracker(app *App) *statsTracker {
	s := &statsTracker{
		Tracker: stats.NewTracker(),
		app: app,
	}
	s.Tracker.AddListener(func(st stats.Stats) {
		app.SetStats(&st)
	})
	return s
}

func (app *App) SetStats(st *stats.Stats) {
	app.mu.Lock()
	defer app.mu.Unlock()
	app.stats = st
}

func (app *App) Stats() *stats.Stats {
	return app.stats
}