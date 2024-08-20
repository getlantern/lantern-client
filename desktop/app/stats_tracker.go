package app

import (
	"github.com/getlantern/flashlight/v7/stats"
	"github.com/getlantern/lantern-client/desktop/ws"
)

type statsTracker struct {
	stats.Tracker
	service *ws.Service
}

func NewStatsTracker() *statsTracker {
	s := &statsTracker{
		Tracker: stats.NewTracker(),
	}
	return s
}

func (s *statsTracker) StartService(channel ws.UIChannel) (err error) {
	helloFn := func(write func(interface{})) {
		log.Debugf("Sending Lantern stats to new client")
		write(s.Latest())
	}
	s.service, err = channel.Register("stats", helloFn)
	if err == nil {
		s.AddListener(func(newStats stats.Stats) {
			log.Debugf("Stats updated: %v", newStats)
			select {
			case s.service.Out <- newStats:
				// ok
			default:
				// don't block if no-one is listening
			}
		})
	}
	return
}

func (app *App) Stats() stats.Stats {
	if app.statsTracker != nil {
		return app.statsTracker.Latest()
	}
	return stats.Stats{}
}
