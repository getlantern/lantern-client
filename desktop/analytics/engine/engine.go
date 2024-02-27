package engine

import "net/url"

const useMatomo = false

type Engine interface {
	End(vals url.Values) url.Values
	GetEndpoint() string
	SetIP(vals url.Values, ip string) url.Values
	SetEventWithLabel(vals url.Values, category, action, label string) url.Values
	GetSessionValues(version, deviceID, execHash string) url.Values
}

func New() Engine {
	if useMatomo {
		return NewMatomo()
	}
	return NewGA()
}
