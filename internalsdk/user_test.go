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
	mockClient := new(mocks.ProClient)
	mockSession := new(mocks.ClientSession)

	// Set up expected behavior
	mockClient.On("UserCreate", mock.Anything).Return(&pro.UserDataResponse{
		User: &protos.User{
			UserId: 123,
			Token:  "test-token",
		},
	}, nil)
	mockClient.On("SetUserIDAndToken", int64(123), "test-token").Return(nil)

	_, err := mockClient.UserCreate(context.Background())
	assert.NoError(t, err, "expected no error")
	// Verify that UserCreate and SetUserIdAndToken were called once
	mockClient.AssertCalled(t, "UserCreate", mock.Anything)
	mockSession.AssertCalled(t, "SetUserIDAndToken", int64(123), "test-token")
}

func TestCreateUser_Failure(t *testing.T) {
	mockClient := new(mocks.ProClient)

	mockClient.On("UserCreate", mock.Anything).Return(nil, errors.New("failed to create user"))

	_, err := mockClient.UserCreate(context.Background())
	assert.Error(t, err, "expected an error")
	mockClient.AssertCalled(t, "UserCreate", mock.Anything)
}

type mockClient struct {
	mock.Mock
}

func (m *mockClient) UpdateUserData(ctx context.Context, session pro.ClientSession) (interface{}, error) {
	args := m.Called(ctx, session)
	return args.Get(0), args.Error(1)
}
