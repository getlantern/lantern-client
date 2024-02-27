package diagnostics

import (
	"github.com/getlantern/diagnostics"
	"github.com/go-ping/ping"
)

// multiPing is like getlantern/diagnostics.Diagnostics.Ping, but for multiple named addresses.
type multiPing struct {
	addresses map[string]string
	count     int
}

func (mp multiPing) Type() string {
	return "multi-ping"
}

// PingResult is the result of a ping test.
type PingResult struct {
	// Only one of the following will be non-nil.
	Stats *ping.Statistics `json:",omitEmpty"`
	Error *string          `json:",omitEmpty"`
}

// Return type: map[string]PingResult. Never returns an error.
func (mp multiPing) RunInSuite() (interface{}, error) {
	indexToName := map[int]string{}
	pingTests := []diagnostics.Diagnostic{}
	for name, addr := range mp.addresses {
		indexToName[len(pingTests)] = name
		pingTests = append(pingTests, &diagnostics.Ping{Address: addr, Count: mp.count, Force: forcePing})
	}

	results := diagnostics.Run(len(pingTests), pingTests...)
	resultsMap := map[string]PingResult{}
	for i, result := range results {
		if result.Error != nil {
			resultsMap[indexToName[i]] = PingResult{Error: result.Error}
		} else {
			stats := result.Result.(*diagnostics.PingResult).Statistics
			resultsMap[indexToName[i]] = PingResult{Stats: stats}
		}
	}
	return resultsMap, nil
}
