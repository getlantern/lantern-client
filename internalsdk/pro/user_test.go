package pro

import (
	"context"
	"testing"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

// Define the mock proClient
type mockProClient struct {
	mock.Mock
}

func (m *mockProClient) UpdateUserData(ctx context.Context, session ClientSession) (*protos.User, error) {
	args := m.Called(ctx, session)
	user, _ := args.Get(0).(*protos.User)
	return user, args.Error(1)
}

// Test PollUserData
func TestPollUserData(t *testing.T) {
	mockClient := new(mockProClient)
	var session ClientSession

	// Configure the mock behavior
	mockClient.On("UpdateUserData", mock.Anything, session).Return(nil, nil)

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	c := &proClient{
		backoffRunner: &backoffRunner{},
	}

	// Run PollUserData
	go c.PollUserData(ctx, session, 10*time.Second, mockClient)

	time.Sleep(12 * time.Second)

	// Count the number of calls
	callCount := 0
	for _, call := range mockClient.Calls {
		if call.Method == "UpdateUserData" {
			callCount++
		}
	}

	// Verify the minimum number of calls
	assert.GreaterOrEqual(t, callCount, 2, "Expected UpdateUserData to be called at least twice")
}

// Test PollUserData Handles Errors
func TestPollUserDataWithError(t *testing.T) {
	mockClient := new(mockProClient)
	var session ClientSession

	// Configure the mock to simulate errors
	mockClient.On("UpdateUserData", mock.Anything, session).Return(nil, errors.New("mock error"))

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	c := &proClient{
		backoffRunner: &backoffRunner{},
	}

	// Run PollUserData
	go c.PollUserData(ctx, session, 5*time.Second, mockClient)

	// Wait for the context to expire
	time.Sleep(6 * time.Second)

	// Verify that UpdateUserData was retried multiple times
	AssertAtLeastCalled(t, &mockClient.Mock, "UpdateUserData", 2)
}

func AssertAtLeastCalled(t *testing.T, mock *mock.Mock, methodName string, minCalls int) {
	callCount := 0
	for _, call := range mock.Calls {
		if call.Method == methodName {
			callCount++
		}
	}
	assert.GreaterOrEqual(t, callCount, minCalls, "Expected at least %d calls to %s, but got %d", minCalls, methodName, callCount)
}
