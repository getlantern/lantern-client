package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"errors"
	"math/big"
	"strings"

	"github.com/1Password/srp"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"golang.org/x/crypto/pbkdf2"
)

const (
	group = srp.RFC5054Group3072
)

func ConvertToUserDetailsResponse(userResponse *protos.LoginResponse) *protos.User {
	// Convert protobuf to usre details struct
	log.Debugf("ConvertToUserDetailsResponse %+v", userResponse)

	user := userResponse.LegacyUserData

	userData := protos.User{
		UserId:       userResponse.LegacyUserData.UserId,
		Code:         user.Code,
		Token:        userResponse.LegacyToken,
		Referral:     user.Code,
		UserLevel:    user.UserLevel,
		Expiration:   user.Expiration,
		Email:        user.Email,
		UserStatus:   user.UserStatus,
		Locale:       user.Locale,
		YinbiEnabled: user.YinbiEnabled,
		Inviters:     user.Inviters,
		Invitees:     user.Invitees,
		// Purchases:    user.Purchases,
	}
	log.Debugf("ConvertToUserDetailsResponse %+v", &userData)

	for _, d := range user.Devices {
		// Map the fields from LoginResponse_Device to UserDevice
		userDevice := &protos.Device{
			Id:      d.Id,
			Name:    d.GetName(),
			Created: d.GetCreated(),
		}
		userData.Devices = append(userData.Devices, userDevice)
	}

	return &userData
}

// Takes password and email, salt and returns encrypted key
func GenerateEncryptedKey(password string, email string, salt []byte) *big.Int {
	lowerCaseEmail := strings.ToLower(email)
	combinedInput := password + lowerCaseEmail
	encryptedKey := pbkdf2.Key([]byte(combinedInput), salt, 4096, 32, sha256.New)
	encryptedKeyBigInt := big.NewInt(0).SetBytes(encryptedKey)
	return encryptedKeyBigInt
}

func (c *authClient) getUserSalt(email string) ([]byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	log.Debugf("Salt not found calling api for %s", email)
	salt, err := c.GetSalt(context.Background(), lowerCaseEmail)
	if err != nil {
		return nil, err
	}
	log.Debugf("Salt Response-> %v", salt.Salt)
	return salt.Salt, nil
}

func GenerateSalt() ([]byte, error) {
	salt := make([]byte, 16)
	if n, err := rand.Read(salt); err != nil {
		return nil, err
	} else if n != 16 {
		return nil, errors.New("failed to generate 16 byte salt")
	}
	return salt, nil
}

func (c *authClient) SignUp(email string, password string) ([]byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	salt, err := GenerateSalt()
	if err != nil {
		return nil, err
	}

	srpClient := srp.NewSRPClient(srp.KnownGroups[group], GenerateEncryptedKey(password, lowerCaseEmail, salt), nil)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return nil, err
	}
	signUpRequestBody := &protos.SignupRequest{
		Email:                 lowerCaseEmail,
		Salt:                  salt,
		Verifier:              verifierKey.Bytes(),
		SkipEmailConfirmation: true,
	}
	log.Debugf("Sign up request email %v, salt %v verifier %v verifiter in bytes %v", lowerCaseEmail, salt, verifierKey, verifierKey.Bytes())
	signupResponse, err := c.signUp(context.Background(), signUpRequestBody)
	if err != nil {
		return nil, err
	}
	log.Debugf("sign up response %v", signupResponse)
	return salt, nil
}

// Todo find way to optimize this method
func (c *authClient) Login(email string, password string, deviceId string) (*protos.LoginResponse, []byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	// Get the salt
	salt, err := c.getUserSalt(lowerCaseEmail)
	if err != nil {
		return nil, nil, err
	}

	encryptedKey := GenerateEncryptedKey(password, lowerCaseEmail, salt)
	log.Debugf("Encrypted key %v Login", encryptedKey)
	// Prepare login request body
	client := srp.NewSRPClient(srp.KnownGroups[group], encryptedKey, nil)
	//Send this key to client
	A := client.EphemeralPublic()
	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	srpB, err := c.LoginPrepare(context.Background(), prepareRequestBody)
	if err != nil {
		return nil, nil, err
	}
	log.Debugf("Login prepare response %v", srpB)

	// // Once the client receives B from the server Client should check error status here as defense against
	// // a malicious B sent from server
	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return nil, nil, err
	}

	// client can now make the session key
	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return nil, nil, log.Errorf("user_not_found error while generating Client key %v", err)
	}

	// // Step 3

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return nil, nil, log.Errorf("user_not_found error while checking server proof%v", err)
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return nil, nil, log.Errorf("user_not_found error while generating client proof %v", err)
	}
	loginRequestBody := &protos.LoginRequest{
		Email:    lowerCaseEmail,
		Proof:    clientProof,
		DeviceId: deviceId,
	}
	log.Debugf("Login request body %v", loginRequestBody)
	resp, err := c.login(context.Background(), loginRequestBody)
	return resp, salt, err
}
