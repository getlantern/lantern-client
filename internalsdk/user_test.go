package internalsdk

import (
	"context"
	"testing"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/mocks"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestCreateUser_Success(t *testing.T) {

	mockProClient := new(mocks.ProClient)
	mockSession := new(mocks.Session)

	// Set up expected behavior
	mockProClient.On("UserCreate", mock.Anything).Return(&pro.UserDataResponse{
		User: &protos.User{
			UserId: 123,
			Token:  "test-token",
		},
	}, nil)
	mockSession.On("SetUserIdAndToken", int64(123), "test-token").Return(nil)

	err := createUser(context.Background(), mockProClient, mockSession)
	assert.NoError(t, err, "expected no error")
	// Verify that UserCreate and SetUserIdAndToken were called once
	mockProClient.AssertCalled(t, "UserCreate", mock.Anything)
	mockSession.AssertCalled(t, "SetUserIdAndToken", int64(123), "test-token")
}

func TestCreateUser_Failure(t *testing.T) {
	mockProClient := new(mocks.ProClient)
	mockSession := new(mocks.Session)

	mockProClient.On("UserCreate", mock.Anything).Return(nil, errors.New("failed to create user"))

	err := createUser(context.Background(), mockProClient, mockSession)
	assert.Error(t, err, "expected an error")
	mockProClient.AssertCalled(t, "UserCreate", mock.Anything)
}
