package common

// AdSettings is an interface for retrieving mobile ad settings from the global config
type AdSettings interface {
	// GetAdProvider gets an ad provider if and only if ads are enabled based on the passed parameters.
	GetAdProvider(isPro bool, countryCode string, daysSinceInstalled int) (AdProvider, error)
}

// AdProvider provides information for displaying an ad and makes decisions on whether or not to display it.
type AdProvider interface {
	GetNativeBannerZoneID() string
	GetStandardBannerZoneID() string
	GetInterstitialZoneID() string
	ShouldShowAd() bool
}
