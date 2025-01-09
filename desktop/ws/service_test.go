package ws

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRegisterWithMsgInitializer(t *testing.T) {
	uiChan := NewUIChannel().(*uiChannel)

	helloFn := func(send func(interface{})) {
		send("hello")
	}

	newMsgFn := func() interface{} {
		return "new message"
	}

	// Test successful registration
	service, err := uiChan.RegisterWithMsgInitializer("testType", helloFn, newMsgFn)
	assert.NoError(t, err)
	assert.NotNil(t, service)
	assert.Equal(t, "testType", service.Type)
	assert.NotNil(t, service.in)
	assert.NotNil(t, service.out)
	assert.NotNil(t, service.stopCh)

	// Test duplicate registration
	assert.Panics(t, func() {
		_, _ = uiChan.RegisterWithMsgInitializer("testType", helloFn, newMsgFn)
	})

	// Test if the service is correctly added to the services map
	uiChan.muServices.RLock()
	registeredService := uiChan.services["testType"]
	uiChan.muServices.RUnlock()
	assert.NotNil(t, registeredService)
	assert.Equal(t, service, registeredService)
}
