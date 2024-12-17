package pro

import (
	"context"
	"sync"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

type ClientSession interface {
	SetExpiration(int64) error
	SetProUser(bool) error
	SetReferralCode(string) error
	SetUserIDAndToken(int64, string) error
	FetchUserData() error
	GetDeviceID() (string, error)
	GetUserFirstVisit() (bool, error)
}

type backoffRunner struct {
	mu        sync.Mutex
	isRunning bool
}

// createUser submits a request to create a new user with the Pro user and
// configures a new client session
func (c *proClient) createUser(ctx context.Context, session ClientSession) error {
	log.Debug("New user, calling user create")
	resp, err := c.UserCreate(ctx)
	if err != nil {
		return errors.New("Could not create new Pro user: %v", err)
	}
	user := resp.User
	if resp.BaseResponse != nil && resp.BaseResponse.Error != "" {
		return errors.New("Could not create new Pro user: %v", err)
	}
	log.Debugf("Successfully created new user with id %d", user.UserId)
	session.SetReferralCode(user.Referral)
	session.SetUserIDAndToken(user.UserId, user.Token)
	session.FetchUserData()
	return nil
}

// RetryCreateUser is used to retry creating a user with an exponential backoff strategy
func (c *proClient) RetryCreateUser(ctx context.Context, ss ClientSession, maxElapsedTime time.Duration) {
	log.Debug("Starting retry handler for user creation")
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 1 * time.Minute
	expBackoff.MaxElapsedTime = maxElapsedTime
	expBackoff.RandomizationFactor = 0.5
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
	currentDevice, err := ss.GetDeviceID()
	if err != nil {
		return nil, log.Errorf("error fetching device id: %v", err)
	}

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
	firstTime, err := ss.GetUserFirstVisit()
	if err != nil {
		return nil, log.Errorf("error fetching user first visit: %v", err)
	}

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

// PollUserData polls for user data with a retry handler up to max elapsed time
func (c *proClient) PollUserData(ctx context.Context, session ClientSession,
	maxElapsedTime time.Duration, client Client) {
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

	timer := time.NewTimer(expBackoff.NextBackOff())
	defer timer.Stop()

	for {
		select {
		case <-ctx.Done():
			log.Errorf("Poll user data cancelled: %v", ctx.Err())
			return
		case <-timer.C:
			user, err := client.UpdateUserData(ctx, session)
			if err != nil {
				if ctx.Err() != nil {
					log.Errorf("UpdateUserData terminated due to context: %v", ctx.Err())
					return
				}
				log.Errorf("UpdateUserData failed: %v", err)
			}

			userIsPro := func(u *protos.User) bool {
				return u != nil && (u.UserLevel == "pro" || u.UserStatus == "active")
			}

			if userIsPro(user) {
				log.Debug("User became Pro. Stopping polling.")
				return
			}

			// Get the next backoff interval
			waitTime := expBackoff.NextBackOff()
			if waitTime == backoff.Stop {
				log.Debug("Exponential backoff reached max elapsed time. Exiting...")
				return
			}
			timer.Reset(waitTime)
		}
	}
}
