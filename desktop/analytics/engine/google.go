package engine

import (
	"net/url"

	"github.com/getlantern/flashlight/v7/common"
)

const (
	// endpoint is the endpoint to report GA data to.
	gaEndpoint = `https://ssl.google-analytics.com/collect`
)

type googleAnalytics struct{}

func NewGA() Engine {
	return &googleAnalytics{}
}

func (ga googleAnalytics) GetEndpoint() string {
	return gaEndpoint
}

func (ga googleAnalytics) SetIP(vals url.Values, ip string) url.Values {
	vals.Set("uip", ip)
	return vals
}

func (ga googleAnalytics) SetEventWithLabel(vals url.Values, category, action, label string) url.Values {
	vals.Set("ec", category)
	vals.Set("ea", action)
	vals.Set("el", label)
	vals.Set("t", "event")
	return vals
}

func (ga googleAnalytics) End(vals url.Values) url.Values {
	vals.Add("sc", "end")
	return vals
}

func (ga googleAnalytics) GetSessionValues(version, clientID, execHash string) url.Values {
	vals := make(url.Values)

	vals.Add("v", "1")
	vals.Add("cid", clientID)
	vals.Add("tid", common.TrackingID)

	// Make call to anonymize the user's IP address -- basically a policy thing
	// where Google agrees not to store it.
	vals.Add("aip", "1")

	// Custom dimension for the Lantern version
	vals.Add("cd1", version)

	// Custom dimension for the hash of the executable. We combine the version
	// to make it easier to interpret in GA.
	vals.Add("cd2", version+"-"+execHash)

	vals.Add("dp", "localhost")
	vals.Add("t", "pageview")

	return vals
}
