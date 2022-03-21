package internalsdk

import (
	"fmt"
	"strings"

	"github.com/getlantern/flashlight/geolookup"
)

type GeoCallback interface {
	SetIP(string)
	SetCountry(string)
	SetRegion(string)
	SetCity(string)
	SetLatitude(float64)
	SetLongitude(float64)
}

// SetGetGeoInfo set's the client's current geo info on the given GeoCallback (if available).
func SetGeoInfo(cb GeoCallback) {
	info, _ := geolookup.GetGeoInfo(0)
	if info == nil {
		return
	}
	cb.SetIP(info.IP)

	if info.City == nil {
		return
	}
	cb.SetCountry(strings.ToLower(info.City.Country.IsoCode))
	if len(info.City.Subdivisions) > 0 {
		cb.SetRegion(fmt.Sprintf("%s-%v", info.City.Country.IsoCode, info.City.Subdivisions[0].IsoCode))
	}
	if len(info.City.City.Names) > 0 {
		cb.SetCity(info.City.City.Names["en"])
	}
	cb.SetLatitude(info.City.Location.Latitude)
	cb.SetLongitude(info.City.Location.Longitude)
}
