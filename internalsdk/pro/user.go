package pro

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// ClientSession includes information needed to createa new client session
type ClientSession interface {
	GetDeviceID() string
	GetUserFirstVisit() bool
	GetUserID() int64
	GetToken() string
	//Locale() string
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
func (c *proClient) RetryCreateUser(ctx context.Context, ss ClientSession) {
	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 3 * time.Second
	expBackoff.MaxInterval = 1 * time.Minute
	expBackoff.MaxElapsedTime = 10 * time.Minute
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
func (c *proClient) PollUserData(ctx context.Context, session ClientSession, onUserData func(*protos.User)) {
	b := c.backoffRunner
	b.mu.Lock()
	if b.isRunning {
		b.mu.Unlock()
		return
	}
	b.isRunning = true
	b.mu.Unlock()

	defer func() {
		b.mu.Lock()
		b.isRunning = false
		b.mu.Unlock()
	}()

	expBackoff := backoff.NewExponentialBackOff()
	expBackoff.Multiplier = 2.0
	expBackoff.InitialInterval = 10 * time.Second
	expBackoff.MaxInterval = 2 * time.Minute
	expBackoff.MaxElapsedTime = 10 * time.Minute
	expBackoff.RandomizationFactor = 0.5 // Add jitter to backoff interval
	timer := time.NewTimer(0)            // Start immediately
	defer timer.Stop()

	for {
		select {
		case <-ctx.Done():
			fmt.Println("Task cancelled:", ctx.Err())
			return
		case <-timer.C:
			// Wait for the timer to expire
			user, err := c.UpdateUserData(ctx, session)
			if err != nil {
				log.Error(err)
			} else if onUserData != nil {
				onUserData(user)
			}

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
