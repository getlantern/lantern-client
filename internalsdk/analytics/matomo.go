package analytics

import (
	"net/url"
)

const (
	// endpoint is the endpoint to report Matomo data to.
	matomoEndpoint  = `https://analytics.lantern.io/matomo.php` // - this should be in an env
	matomoIDSite    = "1"                                       // lantern.io - this should be in an env
	matomoAuthToken = "9da6ac71d684a0cc5dd3c36034699859"        // this should be in an env
)

type matomo struct{}

func NewMatomo() Engine {
	return &matomo{}
}

func (ga matomo) GetEndpoint() string {
	return matomoEndpoint
}

func (ga matomo) SetIP(vals url.Values, ip string) url.Values {
	vals.Set("cip", ip)
	return vals
}

func (ga matomo) SetEventWithLabel(vals url.Values, category, action, label string) url.Values {
	vals.Set("e_c", category)
	vals.Set("e_a", action)
	vals.Set("e_n", label)
	vals.Set("action_name", "event")
	return vals
}

func (ga matomo) End(vals url.Values) url.Values {
	vals.Add("new_visit", "1")
	return vals
}

func (ga matomo) GetSessionValues(version, clientID, execHash string) url.Values {
	vals := make(url.Values)

	vals.Add("apiv", "1")
	vals.Add("rec", "1")

	vals.Add("cid", clientID)
	vals.Add("idsite", matomoIDSite)
	vals.Add("token_auth", matomoAuthToken)

	// Custom dimension for the Lantern version
	vals.Add("dimension1", version)

	// Custom dimension for the hash of the executable. We combine the version
	// to make it easier to interpret in GA.
	vals.Add("dimension2", version+"-"+execHash)

	vals.Add("url", "localhost")
	vals.Add("action_name", "pageview")

	return vals
}
