package pro

import (
	"context"
	"testing"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
)

func TestCreateUser_Success(t *testing.T) {
	mockClient := new(MockProClient)
	mockSession := new(MockClientSession)

	// Set up expected behavior
	mockClient.On("UserCreate", mock.Anything).Return(&UserDataResponse{
		User: &protos.User{
			UserId: 123,
			Token:  "test-token",
		},
	}, nil)
	mockClient.On("SetUserIdAndToken", int64(123), "test-token").Return(nil)

	_, err := mockClient.UserCreate(context.Background())
	assert.NoError(t, err, "expected no error")
	// Verify that UserCreate and SetUserIdAndToken were called once
	mockClient.AssertCalled(t, "UserCreate", mock.Anything)
	mockSession.AssertCalled(t, "SetUserIdAndToken", int64(123), "test-token")
}

func TestCreateUser_Failure(t *testing.T) {
	mockClient := new(MockProClient)

	mockClient.On("UserCreate", mock.Anything).Return(nil, errors.New("failed to create user"))

	_, err := mockClient.UserCreate(context.Background())
	assert.Error(t, err, "expected an error")
	mockClient.AssertCalled(t, "UserCreate", mock.Anything)
}

type mockClient struct {
	mock.Mock
}

func (m *mockClient) UpdateUserData(ctx context.Context, session ClientSession) (interface{}, error) {
	args := m.Called(ctx, session)
	return args.Get(0), args.Error(1)
}
