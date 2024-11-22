package pro

import (
	"context"
	"fmt"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// ClientSession includes information needed to create a new client session
type ClientSession interface {
	GetDeviceID() (string, error)
	GetUserID() (int64, error)
	GetToken() (string, error)
	Locale() (string, error)
	SetUserIdAndToken(int64, string) error
}

func (c *proClient) createUser(ctx context.Context, onUserCreate func(*protos.User)) error {
	log.Debug("New user, calling user create")
	resp, err := c.UserCreate(ctx)
	if err != nil {
		return errors.New("Could not create new Pro user: %v", err)
	}
	user := resp.User
	log.Debugf("DEBUG: User created: %v", user)
	if resp.BaseResponse != nil && resp.BaseResponse.Error != "" {
		return errors.New("Could not create new Pro user: %v", err)
	}
	if onUserCreate != nil {
		onUserCreate(resp.User)
	}
	return nil
}

// RetryCreateUser is used to retry creating a user with an exponential backoff strategy
func (c *proClient) RetryCreateUser(ctx context.Context, onUserCreate func(*protos.User)) {
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 1 * time.Minute
	expBackoff.MaxElapsedTime = 10 * time.Minute
	expBackoff.RandomizationFactor = 0.5 // Add jitter to backoff interval
	err := backoff.Retry(func() error {
		return c.createUser(ctx, onUserCreate)
	}, backoff.WithContext(expBackoff, ctx))
	if err != nil {
		log.Fatal("Unable to create Lantern user after max retries")
	}
}

func (c *proClient) updateUserData(ctx context.Context, onUserData func(*protos.User)) error {
	resp, err := c.UserData(ctx)
	if err != nil {
		return errors.New("error fetching user data: %v", err)
	} else if resp.User == nil {
		return errors.New("error fetching user data")
	}
	if onUserData != nil {
		onUserData(resp.User)
	}
	return nil
}

// RetryCreateUser is used to retry creating a user with an exponential backoff strategy
func (c *proClient) PollUserData(ctx context.Context, onUserData func(*protos.User)) {
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 10 * time.Minute
	expBackoff.MaxElapsedTime = 10 * time.Minute
	expBackoff.RandomizationFactor = 0.5 // Add jitter to backoff interval
	timer := time.NewTimer(0)            // Start immediately
	defer timer.Stop()

	for {
		select {
		case <-ctx.Done():
			return
		case <-timer.C:
			// Wait for the timer to expire
			c.updateUserData(ctx, onUserData)

			// Get the next backoff interval
			waitTime := expBackoff.NextBackOff()
			if waitTime == backoff.Stop {
				expBackoff.Reset()
				waitTime = expBackoff.NextBackOff()
			}
			fmt.Printf("Next attempt in %v...\n", waitTime)
			// Reset the timer with the next backoff interval
			timer.Reset(waitTime)
		}
	}
}
