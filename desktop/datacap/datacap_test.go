package datacap

import (
	"fmt"
	"strconv"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"

	"github.com/getlantern/flashlight/v7/bandwidth"
	"github.com/getlantern/lantern-client/desktop/ws"
)

func TestServeCap(t *testing.T) {
	err := ServeDataCap(ws.NewUIChannel(), func() string {
		return ""
	}, func() string {
		return ""
	}, func() (bool, bool) {
		return false, false
	})
	assert.NoError(t, err)

	dc := &dataCap{iconURL: func() string {
		return ""
	}, clickURL: func() string {
		return ""
	}, isPro: func() (bool, bool) {
		return false, false
	}}

	hit := false
	listener := func(hitDataCap bool) {
		hit = hitDataCap
	}
	AddDataCapListener(listener)
	out := make(chan<- interface{}, 2)
	quota := &bandwidth.Quota{MiBAllowed: 10, MiBUsed: 10, AsOf: time.Now()}
	dc.processQuota(out, quota)

	assert.True(t, hit)

	quota = &bandwidth.Quota{MiBAllowed: 10, MiBUsed: 1, AsOf: time.Now()}
	dc.processQuota(out, quota)
}

func TestPercents(t *testing.T) {
	ns := dataCap{}

	quota := &bandwidth.Quota{
		MiBAllowed: 1000,
		MiBUsed:    801,
	}

	assert.True(t, ns.isEightyOrMore(quota))

	quota.MiBUsed = 501
	assert.False(t, ns.isEightyOrMore(quota))
	assert.True(t, ns.isFiftyOrMore(quota))

	msg := "you have used %s of your data"
	expected := "you have used 80% of your data"
	assert.Equal(t, expected, percentMsg(msg, 80))
}

func percentMsg(msg string, percent int) string {
	str := strconv.Itoa(percent) + "%"
	return fmt.Sprintf(msg, str)
}
