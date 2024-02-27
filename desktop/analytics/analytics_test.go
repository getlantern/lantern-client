package analytics

import (
	"bytes"
	"errors"
	"io/ioutil"
	"net/http"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"github.com/getlantern/flashlight/v7/common"

	"github.com/stretchr/testify/assert"
)

type errorTripper struct {
	request *http.Request
}

func (et *errorTripper) RoundTrip(r *http.Request) (*http.Response, error) {
	et.request = r
	return nil, errors.New("error")
}

type successTripper struct {
	numRequests int32
	request     *http.Request
}

func (st *successTripper) RoundTrip(r *http.Request) (*http.Response, error) {
	st.request = r
	atomic.AddInt32(&st.numRequests, 1)
	t := &http.Response{
		Body: ioutil.NopCloser(bytes.NewBufferString("Hello World")),
	}

	return t, nil
}

func TestRoundTrip(t *testing.T) {
	et := &errorTripper{}
	session := newSession("1", "2.2.0", 0, et)
	session.track()
	assert.Equal(t, "application/x-www-form-urlencoded", et.request.Header.Get("Content-Type"), "unexpected content type")

	st := &successTripper{}
	session.rt = st
	session.track()
	assert.Equal(t, "application/x-www-form-urlencoded", st.request.Header.Get("Content-Type"), "unexpected content type")
}

func TestKeepalive(t *testing.T) {
	st := &successTripper{}
	session := newSession("1", "2.2.0", 100*time.Millisecond, st)
	go session.keepalive()
	time.Sleep(110 * time.Millisecond)
	assert.EqualValues(t, 1, atomic.LoadInt32(&st.numRequests), "Should have sent keepalive after the inteval")
	time.Sleep(20 * time.Millisecond)
	session.Event("category", "action")
	// have to wait because event is sent asynchronously
	time.Sleep(10 * time.Millisecond)
	assert.EqualValues(t, 2, atomic.LoadInt32(&st.numRequests), "Should have sent event")
	time.Sleep(80 * time.Millisecond)
	assert.EqualValues(t, 2, atomic.LoadInt32(&st.numRequests), "Other requests should reset the keepalive timer")
	time.Sleep(30 * time.Millisecond)
	assert.EqualValues(t, 3, atomic.LoadInt32(&st.numRequests), "Should have sent another keepalive after the new timer expired")
}

func TestAnalytics(t *testing.T) {
	session := newSession("1", "2.2.0", 0, http.DefaultTransport)
	session.SetIP("127.0.0.1")

	argString := session.vals.Encode()
	assert.True(t, strings.Contains(argString, "pageview"))
	assert.True(t, strings.Contains(argString, "127.0.0.1"))

	// Now actually hit the GA debug server to validate the hit.
	url := "https://www.google-analytics.com/debug/collect?" + argString
	resp, err := http.Get(url)
	if !assert.NoError(t, err, "Should have no error") {
		return
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	assert.Nil(t, err, "Should be nil")

	assert.True(t, strings.Contains(string(body), "\"valid\": true"), "Should be a valid hit")

	session.End()
}

func TestAddCampaign(t *testing.T) {
	startURL := "https://test.com"
	campaignURL, err := AddCampaign(startURL, "test-campaign", "test-content", "test-medium")
	assert.NoError(t, err)
	assert.Equal(t, "https://test.com?utm_campaign=test-campaign&utm_content=test-content&utm_medium=test-medium&utm_source="+common.Platform, campaignURL)

	// Now test a URL that will produce an error
	startURL = ":"
	_, err = AddCampaign(startURL, "test-campaign", "test-content", "test-medium")
	assert.Error(t, err)
}
