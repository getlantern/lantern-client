package internalsdk

import (
	"github.com/getlantern/flashlight/v7/stats"
)

type statsTracker struct {
	stats.Tracker
	session PanickingSession
}

func NewStatsTracker(session PanickingSession) *statsTracker {
	s := &statsTracker{
		Tracker: stats.NewTracker(),
		session: session,
	}
	s.Tracker.AddListener(func(st stats.Stats) {
		s.session.UpdateStats(
			st.City,
			st.Country,
			st.CountryCode,
			st.HTTPSUpgrades,
			st.AdsBlocked,
			st.HasSucceedingProxy)
	})
	return s
}
