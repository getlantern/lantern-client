package notifier

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"

	notify "github.com/getlantern/notifier"

	"github.com/getlantern/lantern-client/internalsdk/analytics"
)

func TestNotify(t *testing.T) {
	stop := loopFor(10*time.Millisecond, analytics.NullSession{})
	stop()

	stop = loopFor(10*time.Millisecond, analytics.NullSession{})
	note := &notify.Notification{
		Title:    "test",
		Message:  "test",
		ClickURL: "https://test.com",
		IconURL:  "https://test.com",
	}

	shown := ShowNotification(note, "test-campaign")

	assert.True(t, shown)
	stop()
}
