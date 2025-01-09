package geolookup

import (
	"net"
	"net/http"
	"os"
	"testing"
	"time"

	"github.com/getlantern/eventual/v2"
	"github.com/getlantern/fronted"
	"github.com/stretchr/testify/require"
)

const initialInfo = `
{
    "City": {
        "City": {
            "GeoNameID": 4671654,
            "Names": {
                "de": "Austin",
                "en": "Austin",
                "es": "Austin",
                "fr": "Austin",
                "ja": "\u30aa\u30fc\u30b9\u30c6\u30a3\u30f3",
                "pt-BR": "Austin",
                "ru": "\u041e\u0441\u0442\u0438\u043d"
            }
        },
        "Continent": {
            "Code": "NA",
            "GeoNameID": 6255149,
            "Names": {
                "de": "Nordamerika",
                "en": "North America",
                "es": "Norteam\u00e9rica",
                "fr": "Am\u00e9rique du Nord",
                "ja": "\u5317\u30a2\u30e1\u30ea\u30ab",
                "pt-BR": "Am\u00e9rica do Norte",
                "ru": "\u0421\u0435\u0432\u0435\u0440\u043d\u0430\u044f \u0410\u043c\u0435\u0440\u0438\u043a\u0430",
                "zh-CN": "\u5317\u7f8e\u6d32"
            }
        },
        "Country": {
            "GeoNameID": 6252001,
            "IsoCode": "FM",
            "Names": {
                "de": "USA",
                "en": "United States",
                "es": "Estados Unidos",
                "fr": "\u00c9tats Unis",
                "ja": "\u30a2\u30e1\u30ea\u30ab",
                "pt-BR": "EUA",
                "ru": "\u0421\u0428\u0410",
                "zh-CN": "\u7f8e\u56fd"
            }
        },
        "Location": {
            "Latitude": 30.2095,
            "Longitude": -97.7972,
            "MetroCode": 635,
            "TimeZone": "America/Chicago"
        },
        "Postal": {
            "Code": "78745"
        },
        "RegisteredCountry": {
            "GeoNameID": 6252001,
            "IsoCode": "US",
            "Names": {
                "de": "USA",
                "en": "United States",
                "es": "Estados Unidos",
                "fr": "\u00c9tats Unis",
                "ja": "\u30a2\u30e1\u30ea\u30ab",
                "pt-BR": "EUA",
                "ru": "\u0421\u0428\u0410",
                "zh-CN": "\u7f8e\u56fd"
            }
        },
        "RepresentedCountry": {
            "GeoNameID": 0,
            "IsoCode": "",
            "Names": null,
            "Type": ""
        },
        "Subdivisions": [
            {
                "GeoNameID": 4736286,
                "IsoCode": "TX",
                "Names": {
                    "en": "Texas",
                    "es": "Texas",
                    "fr": "Texas",
                    "ja": "\u30c6\u30ad\u30b5\u30b9\u5dde",
                    "ru": "\u0422\u0435\u0445\u0430\u0441",
                    "zh-CN": "\u5fb7\u514b\u8428\u65af\u5dde"
                }
            }
        ],
        "Traits": {
            "IsAnonymousProxy": false,
            "IsSatelliteProvider": false
        }
    },
    "IP": "999.999.999.999"
}
`

func TestGetIP(t *testing.T) {
	currentGeoInfo = eventual.NewValue()
	roundTripper = &http.Transport{
		Dial: (&net.Dialer{
			Timeout: 10 * time.Second,
		}).Dial,
	}
	ip := GetIP(0)
	require.Equal(t, "", ip)
	go Refresh()
	ip = GetIP(-1)
	addr := net.ParseIP(ip)
	require.NotNil(t, addr)
}

func TestGetCountry(t *testing.T) {
	currentGeoInfo = eventual.NewValue()
	roundTripper = &http.Transport{
		Dial: (&net.Dialer{
			Timeout: 10 * time.Second,
		}).Dial,
	}

	country := GetCountry(0)
	require.Equal(t, "", country)
	go Refresh()
	country = GetCountry(-1)
	require.NotEmpty(t, country)
}

func TestFronted(t *testing.T) {
	currentGeoInfo = eventual.NewValue()
	geoFile, err := os.CreateTemp("", "")
	require.NoError(t, err)
	defer os.Remove(geoFile.Name())

	os.WriteFile(geoFile.Name(), []byte(initialInfo), 0644)

	fronted.ConfigureHostAlaisesForTest(t, map[string]string{
		"geo.getiantem.org": "d3u5fqukq7qrhd.cloudfront.net",
	})

	// test persistence
	ch := OnRefresh()
	EnablePersistence(geoFile.Name())
	country := GetCountry(0)
	require.Equal(t, "FM", country, "Should immediately get persisted country")
	select {
	case <-ch:
		// okay
	case <-time.After(5 * time.Second):
		t.Error("should update watcher after enabling persistence")
	}

	// clear initial value to make sure we read value from network
	currentGeoInfo.Reset()
	Refresh()
	country = GetCountry(60 * time.Second)
	ip := GetIP(5 * time.Second)
	require.Len(t, country, 2, "Bad country '%v' for ip %v", country, ip)
	require.NotEqual(
		t,
		"FM",
		country,
		"Should have gotten a new country from network (note, this test will fail if run in Micronesia)",
	)
	require.True(t, len(ip) >= 7, "Bad IP %s", ip)

	t.Log("Waiting for refresh again")
	select {
	case <-ch:
		// okay
	case <-time.After(5 * time.Second):
		t.Error("should update watcher after network refresh")
	}

	// Give persistence time to finish
	time.Sleep(1 * time.Second)
	b, err := os.ReadFile(geoFile.Name())
	require.NoError(t, err)
	require.NotEmpty(t, b)
	require.NotEqual(
		t,
		initialInfo,
		string(b),
		"persisted geolocation information should have changed",
	)
}

func TestIsNew(t *testing.T) {
	type args struct {
		newGeoInfo *GeoInfo
		oldGeoInfo *GeoInfo
	}
	tests := []struct {
		name string
		args args
		want bool
	}{
		{"nil new should be not new", args{nil, &GeoInfo{FromDisk: true}}, false},
		{"nil existing should be new", args{&GeoInfo{}, nil}, true},
		{"old from disk should be new", args{&GeoInfo{IP: "1.1.1.1", FromDisk: false}, &GeoInfo{IP: "1.1.1.1", FromDisk: true}}, true},
		{"old not from disk should not be new", args{&GeoInfo{IP: "1.1.1.1", FromDisk: false}, &GeoInfo{IP: "1.1.1.1", FromDisk: false}}, false},
		{"new IP should be new", args{&GeoInfo{IP: "1.1.1.2", FromDisk: false}, &GeoInfo{IP: "1.1.1.1", FromDisk: false}}, true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			currentGeoInfo.Set(tt.args.oldGeoInfo)
			if got := isNew(tt.args.newGeoInfo); got != tt.want {
				t.Errorf("isNew() = %v, want %v", got, tt.want)
			}
		})
	}
}
