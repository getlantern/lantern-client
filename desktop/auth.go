package main

import "C"

import (
	"context"
	"fmt"
	"math/big"
	"strings"

	"github.com/getlantern/lantern-client/internalsdk/auth"
	"github.com/getlantern/lantern-client/internalsdk/protos"
)

// Auth Methods

//export isUserFirstTime
func isUserFirstTime() *C.char {
	firstVisit := getApp().Settings().GetUserFirstVisit()
	stringValue := fmt.Sprintf("%t", firstVisit)
	return C.CString(stringValue)
}

//export setFirstTimeVisit
func setFirstTimeVisit() {
	getApp().Settings().SetUserFirstVisit(false)
}

//export isUserLoggedIn
func isUserLoggedIn() *C.char {
	loggedIn := getApp().IsUserLoggedIn()
	stringValue := fmt.Sprintf("%t", loggedIn)
	log.Debugf("User logged in %v", stringValue)
	return C.CString(stringValue)
}

func getUserSalt(email string) ([]byte, error) {
	lowerCaseEmail := strings.ToLower(email)
	a := getApp()
	salt := a.Settings().GetSalt()
	if len(salt) == 16 {
		log.Debugf("salt return from cache %v", salt)
		return salt, nil
	}
	log.Debugf("Salt not found calling api for %s", email)
	saltResponse, err := a.AuthClient().GetSalt(context.Background(), lowerCaseEmail)
	if err != nil {
		return nil, err
	}
	log.Debugf("Salt Response-> %v", saltResponse.Salt)
	return saltResponse.Salt, nil

}

// Authenticates the user with the given email and password.
//
//	Note-: On Sign up Client needed to generate 16 byte slat
//	Then use that salt, password and email generate encryptedKey once you created encryptedKey pass it to srp.NewSRPClient
//	Then use srpClient.Verifier() to generate verifierKey

//export signup
func signup(email *C.char, password *C.char) *C.char {
	a := getApp()
	lowerCaseEmail := strings.ToLower(C.GoString(email))

	salt, err := a.AuthClient().SignUp(lowerCaseEmail, C.GoString(password))
	if err != nil {
		return sendError(err)
	}
	// save salt and email in settings
	setting := a.Settings()
	saveUserSalt(salt)
	setting.SetEmailAddress(C.GoString(email))
	a.SetUserLoggedIn(true)
	a.ProClient().FetchPaymentMethodsAndCache(context.Background())
	return C.CString("true")
}

//export login
func login(email *C.char, password *C.char) *C.char {
	a := getApp()
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	user, salt, err := a.AuthClient().Login(lowerCaseEmail, C.GoString(password), getDeviceID())
	if err != nil {
		return sendError(err)
	}
	// User has more than 3 device connected to device
	if !user.Success {
		err := deviceLimitFlow(user)
		if err != nil {
			return sendError(log.Errorf("error while starting device limit flow %v", err))
		}
		return sendError(log.Errorf("too-many-devices %v", err))
	}

	log.Debugf("User login successfull %+v", user)
	// save salt and email in settings
	saveUserSalt(salt)
	a.SetUserLoggedIn(true)
	userData := auth.ConvertToUserDetailsResponse(user)
	// once login is successfull save user details
	// but overide there email with login email
	// old email might be differnt but we want to show latets email
	userData.Email = C.GoString(email)
	a.Settings().SetEmailAddress(userData.Email)
	a.SetUserData(context.Background(), user.LegacyID, userData)
	return C.CString("true")
}

//export logout
func logout() *C.char {
	ctx := context.Background()
	a := getApp()
	email := a.Settings().GetEmailAddress()
	deviceId := getDeviceID()
	token := a.Settings().GetToken()
	userId := a.Settings().GetUserID()

	signoutData := &protos.LogoutRequest{
		Email:        email,
		DeviceId:     deviceId,
		LegacyToken:  token,
		LegacyUserID: userId,
	}
	log.Debugf("Sign out request %+v", signoutData)
	loggedOut, logoutErr := a.AuthClient().SignOut(ctx, signoutData)
	if logoutErr != nil {
		return sendError(log.Errorf("Error while signing out %v", logoutErr))
	}
	if !loggedOut {
		return sendError(log.Error("Error while signing out"))
	}

	clearLocalUserData()
	// Create new user
	if _, err := a.ProClient().UserCreate(ctx); err != nil {
		return sendError(err)
	}
	return C.CString("true")
}

// User has reached device limit
// Save latest device
func deviceLimitFlow(login *protos.LoginResponse) error {
	var protoDevices []*protos.Device
	for _, device := range login.Devices {
		protoDevice := &protos.Device{
			Id:      device.Id,
			Name:    device.Name,
			Created: device.Created,
		}
		protoDevices = append(protoDevices, protoDevice)
	}

	user := &protos.User{
		UserId:  login.LegacyID,
		Token:   login.LegacyToken,
		Devices: protoDevices,
	}

	getApp().SetUserData(context.Background(), login.LegacyID, user)
	return nil
}

// Send recovery code to user email
//
//export startRecoveryByEmail
func startRecoveryByEmail(email *C.char) *C.char {
	//Create body
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	prepareRequestBody := &protos.StartRecoveryByEmailRequest{
		Email: lowerCaseEmail,
	}
	recovery, err := getApp().AuthClient().StartRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("StartRecoveryByEmail response %v", recovery)
	return C.CString("true")
}

// Complete recovery by email
//
//export completeRecoveryByEmail
func completeRecoveryByEmail(email *C.char, code *C.char, password *C.char) *C.char {
	//Create body
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	newsalt, err := auth.GenerateSalt()
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Slat %v and length %v", newsalt, len(newsalt))
	srpClient := auth.NewSRPClient(lowerCaseEmail, C.GoString(password), newsalt)
	verifierKey, err := srpClient.Verifier()
	if err != nil {
		return sendError(err)
	}
	prepareRequestBody := &protos.CompleteRecoveryByEmailRequest{
		Email:       lowerCaseEmail,
		Code:        C.GoString(code),
		NewSalt:     newsalt,
		NewVerifier: verifierKey.Bytes(),
	}

	log.Debugf("new Verifier %v and salt %v", verifierKey.Bytes(), newsalt)
	recovery, err := getApp().AuthClient().CompleteRecoveryByEmail(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	//User has been recovered successfully
	//Save new salt
	saveUserSalt(newsalt)
	log.Debugf("CompleteRecoveryByEmail response %v", recovery)
	return C.CString("true")
}

// // This will validate code send by server
//
//export validateRecoveryByEmail
func validateRecoveryByEmail(email *C.char, code *C.char) *C.char {
	lowerCaseEmail := strings.ToLower(C.GoString(email))
	prepareRequestBody := &protos.ValidateRecoveryCodeRequest{
		Email: lowerCaseEmail,
		Code:  C.GoString(code),
	}
	recovery, err := getApp().AuthClient().ValidateEmailRecoveryCode(context.Background(), prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	if !recovery.Valid {
		return sendError(log.Errorf("invalid_code Error: %v", err))
	}
	log.Debugf("Validate code response %v", recovery.Valid)
	return C.CString("true")
}

// This will delete user accoutn and creates new user
//
//export deleteAccount
func deleteAccount(password *C.char) *C.char {
	ctx := context.Background()
	a := getApp()
	authClient := a.AuthClient()
	email := a.Settings().GetEmailAddress()
	lowerCaseEmail := strings.ToLower(email)
	// Get the salt
	salt, err := getUserSalt(lowerCaseEmail)
	if err != nil {
		return sendError(err)
	}
	// Prepare login request body
	client := auth.NewSRPClient(lowerCaseEmail, C.GoString(password), salt)

	//Send this key to client
	A := client.EphemeralPublic()
	//Create body
	prepareRequestBody := &protos.PrepareRequest{
		Email: lowerCaseEmail,
		A:     A.Bytes(),
	}
	log.Debugf("Delete Account request email %v A %v", lowerCaseEmail, A.Bytes())
	srpB, err := authClient.LoginPrepare(ctx, prepareRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Login prepare response %v", srpB.B)

	// // Once the client receives B from the server Client should check error status here as defense against
	// // a malicious B sent from server
	B := big.NewInt(0).SetBytes(srpB.B)

	if err = client.SetOthersPublic(B); err != nil {
		log.Errorf("Error while setting srpB %v", err)
		return sendError(err)
	}

	// client can now make the session key
	clientKey, err := client.Key()
	if err != nil || clientKey == nil {
		return sendError(log.Errorf("user_not_found error while generating Client key %v", err))
	}

	// // Step 3

	// // check if the server proof is valid
	if !client.GoodServerProof(salt, lowerCaseEmail, srpB.Proof) {
		return sendError(log.Error("user_not_found error while checking server proof"))
	}

	clientProof, err := client.ClientProof()
	if err != nil {
		return sendError(log.Errorf("user_not_found error while generating client proof %v", err))
	}
	deviceId := a.Settings().GetDeviceID()

	changeEmailRequestBody := &protos.DeleteUserRequest{
		Email:     lowerCaseEmail,
		Proof:     clientProof,
		Permanent: true,
		DeviceId:  deviceId,
	}

	log.Debugf("Delete Account request email %v prooof %v deviceId %v", lowerCaseEmail, clientProof, deviceId)
	isAccountDeleted, err := authClient.DeleteAccount(context.Background(), changeEmailRequestBody)
	if err != nil {
		return sendError(err)
	}
	log.Debugf("Account deleted response %v", isAccountDeleted)

	if !isAccountDeleted {
		return sendError(log.Errorf("user_not_found error while deleting account %v", err))
	}

	// Clear local user data
	clearLocalUserData()
	// Set user id and token to nil
	a.Settings().SetUserIDAndToken(0, "")
	// Create new user
	if _, err := a.ProClient().UserCreate(ctx); err != nil {
		return sendError(err)
	}
	return C.CString("true")
}
