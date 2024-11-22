package pro

import (
	"context"
	"sync"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// UserConfig represents the minimal configuration necessary for a client session
type UserConfig interface {
	GetDeviceID() string
	GetUserFirstVisit() bool
	GetUserID() int64
	GetToken() string
	Locale() string
}

// ClientSession represents a client session
type ClientSession interface {
	UserConfig
	SetExpiration(int64)
	SetProUser(bool)
	SetReferralCode(string)
	SetUserIDAndToken(int64, string)
}

type backoffRunner struct {
	mu        sync.Mutex
	isRunning bool
}

func (c *proClient) createUser(ctx context.Context, session ClientSession) error {
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
	session.SetReferralCode(user.Referral)
	session.SetUserIDAndToken(user.UserId, user.Token)
	return nil
}

// RetryCreateUser is used to retry creating a user with an exponential backoff strategy
func (c *proClient) RetryCreateUser(ctx context.Context, ss ClientSession, maxElapsedTime time.Duration) {
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 1 * time.Minute
	expBackoff.MaxElapsedTime = maxElapsedTime
	expBackoff.RandomizationFactor = 0.5 // Add jitter to backoff interval
	err := backoff.Retry(func() error {
		return c.createUser(ctx, ss)
	}, backoff.WithContext(expBackoff, ctx))
	if err != nil {
		log.Fatal("Unable to create Lantern user after max retries")
	}
}

func (c *proClient) UpdateUserData(ctx context.Context, ss ClientSession) (*protos.User, error) {
	resp, err := c.UserData(ctx)
	if err != nil {
		return nil, errors.New("error fetching user data: %v", err)
	} else if resp.User == nil {
		return nil, errors.New("error fetching user data")
	}
	user := resp.User
	currentDevice := ss.GetDeviceID()

	// Check if device id is connect to same device if not create new user
	// this is for the case when user removed device from other device
	deviceFound := false
	if user.Devices != nil {
		for _, device := range user.Devices {
			if device.Id == currentDevice {
				deviceFound = true
				break
			}
		}
	}
	/// Check if user has installed app first time
	firstTime := ss.GetUserFirstVisit()
	log.Debugf("First time visit %v", firstTime)
	if user.UserLevel == "pro" && firstTime {
		log.Debugf("User is pro and first time")
		ss.SetProUser(true)
	} else if user.UserLevel == "pro" && !firstTime && deviceFound {
		log.Debugf("User is pro and not first time")
		ss.SetProUser(true)
	} else {
		log.Debugf("User is not pro")
		ss.SetProUser(false)
	}
	ss.SetUserIDAndToken(user.UserId, user.Token)
	ss.SetExpiration(user.Expiration)
	ss.SetReferralCode(user.Referral)
	return user, nil
}

// RetryCreateUser is used to retry creating a user with an exponential backoff strategy
func (c *proClient) PollUserData(ctx context.Context, session ClientSession, maxElapsedTime time.Duration) {
	log.Debug("Polling user data")
	b := c.backoffRunner
	b.mu.Lock()
	if b.isRunning {
		b.mu.Unlock()
		return
	}
	b.isRunning = true
	b.mu.Unlock()

	ctx, cancel := context.WithTimeout(ctx, maxElapsedTime)
	defer func() {
		cancel()
		b.mu.Lock()
		b.isRunning = false
		b.mu.Unlock()
	}()

	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 10 * time.Second
	expBackoff.MaxInterval = 2 * time.Minute
	expBackoff.MaxElapsedTime = maxElapsedTime
	// Add jitter to backoff interval
	expBackoff.RandomizationFactor = 0.5

	if _, err := c.UpdateUserData(ctx, session); err != nil {
		log.Errorf("Initial user data update failed: %v", err)
	}

	timer := time.NewTimer(expBackoff.NextBackOff())
	defer timer.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Errorf("Poll user data cancelled: %v", ctx.Err())
			return
		case <-timer.C:
			_, err := c.UpdateUserData(ctx, session)
			if err != nil {
				if ctx.Err() != nil {
					log.Errorf("UpdateUserData terminated due to context: %v", ctx.Err())
					return
				}
				log.Errorf("UpdateUserData failed: %v", err)
			}

			// Get the next backoff interval
			waitTime := expBackoff.NextBackOff()
			if waitTime == backoff.Stop {
				log.Debug("Exponential backoff reached max elapsed time. Exiting...")
				timer.Stop()
				return
			}
			timer.Reset(waitTime)
		}
	}
}
