package internalsdk

import (
	"github.com/getlantern/flashlight/stats"
)

type statsTracker struct {
	stats.Tracker
	session Session
}

func NewStatsTracker(session Session) *statsTracker {
	s := &statsTracker{
		Tracker: stats.NewTracker(),
		session: session,
	}
	s.Tracker.AddListener(func(st stats.Stats) {
		s.session.UpdateStats(st.City, st.Country,
			st.CountryCode, st.HTTPSUpgrades, st.AdsBlocked)
	})
	return s
}
