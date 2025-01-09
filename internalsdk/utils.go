package internalsdk

import (
	"bytes"
	"crypto/rand"
	cryptoRand "crypto/rand"
	"crypto/sha256"
	"encoding/binary"
	"fmt"
	"math"
	"math/big"
	"os"
	"strconv"
	"strings"
	"time"

	"golang.org/x/crypto/pbkdf2"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/common"
	"github.com/getlantern/lantern-client/internalsdk/pro"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/pathdb"
)

// createProClient creates a new instance of ProClient with the given client session information
func createProClient(session Session, platform string) pro.ProClient {
	return pro.NewClient(common.ProAPIBaseURL, func() common.UserConfig {
		internalHeaders := map[string]string{
			common.PlatformHeader:   platform,
			common.AppVersionHeader: common.ApplicationVersion,
		}
		deviceID, _ := session.GetDeviceID()
		userID, _ := session.GetUserID()
		token, _ := session.GetToken()
		lang, _ := session.Locale()
		return common.NewUserConfig(
			common.DefaultAppName,
			deviceID,
			userID,
			token,
			internalHeaders,
			lang,
		)
	})
}

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}

// Create Purchase Request
func createPurchaseData(session *SessionModel, email string, paymentProvider string, resellerCode string, purchaseToken string, planId string) (error, map[string]interface{}) {
	if email == "" && paymentProvider != paymentProviderApplePay {
		return errors.New("Email is empty"), nil
	}

	device, err := pathdb.Get[string](session.db, pathModel)
	if err != nil {
		return err, nil
	}
	data := map[string]interface{}{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       paymentProvider,
		"email":          email,
		"deviceName":     device,
	}
	switch paymentProvider {
	case paymentProviderResellerCode:
		data["provider"] = paymentProviderResellerCode
		data["resellerCode"] = resellerCode
	case paymentProviderGooglePlay:
		// get currency from plan id
		parts := strings.Split(planId, "-")
		if len(parts) != 3 {
			return errors.New("Invalid plan id"), nil
		}
		cur := parts[1]
		data["token"] = purchaseToken
		data["plan"] = planId
		data["currency"] = cur
	case paymentProviderApplePay:
		// get currency from plan id
		parts := strings.Split(planId, "-")
		if len(parts) != 3 {
			return errors.New("Invalid plan id"), nil
		}
		cur := parts[1]
		data["token"] = purchaseToken
		data["plan"] = planId
		data["currency"] = cur

	case paymentProviderStripe:
		// get currency from plan id
		parts := strings.Split(planId, "-")
		if len(parts) != 3 {
			return errors.New("Invalid plan id"), nil
		}
		cur := parts[1]
		data["token"] = purchaseToken
		data["plan"] = planId
		data["currency"] = cur
	}

	return nil, data
}

func BytesToInt64Slice(b []byte) []int {
	var int64Slice []int
	buf := bytes.NewBuffer(b)

	for buf.Len() >= 8 {
		var n int
		if err := binary.Read(buf, binary.BigEndian, &n); err != nil {
			fmt.Println("binary.Read failed:", err)
			return nil
		}
		int64Slice = append(int64Slice, n)
	}

	return int64Slice
}

func Int64SliceToBytes(int64Slice []int) []byte {
	var buf bytes.Buffer
	for _, n := range int64Slice {
		if err := binary.Write(&buf, binary.BigEndian, n); err != nil {
			fmt.Println("binary.Write failed:", err)
			return nil
		}
	}
	return buf.Bytes()
}

var maxDigit = big.NewInt(9)

func GenerateRandomString(length int) string {
	random := ""

	for i := 0; i < length; i++ {
		bb, _ := cryptoRand.Int(cryptoRand.Reader, maxDigit)
		random += bb.String()
	}
	return random
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

func ToString(value int64) string {
	return fmt.Sprintf("%d", value)
}

func StringToIntSlice(str string) ([]int, error) {
	var slice []int

	for _, char := range str {
		digit, err := strconv.Atoi(string(char))
		if err != nil {
			return nil, err
		}
		slice = append(slice, digit)
	}

	return slice, nil
}

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

func convertIntArrayToByteArray(intArray []int) ([]byte, error) {
	byteArray := make([]byte, len(intArray))
	for i, val := range intArray {
		if val < 0 || val > 255 {
			return nil, fmt.Errorf("value out of byte range: %d", val)
		}
		byteArray[i] = byte(val)
	}
	return byteArray, nil
}

// Function to convert a slice of strings to a slice of ints
func convertStringArrayToIntArray(stringArray []string) ([]int, error) {
	intArray := make([]int, len(stringArray))
	for i, s := range stringArray {
		// Convert each string to an int
		val, err := strconv.Atoi(s)
		if err != nil {
			return nil, err
		}
		intArray[i] = val
	}
	return intArray, nil
}

func convertLogoToMapStringSlice(logo map[string]interface{}) (map[string][]string, error) {
	convertedLogo := make(map[string][]string)
	for key, value := range logo {
		switch value.(type) {
		case []string:
			convertedLogo[key] = value.([]string)
		case []interface{}:
			var stringSlice []string
			for _, item := range value.([]interface{}) {
				if str, ok := item.(string); ok {
					stringSlice = append(stringSlice, str)
				} else {
					// Handle non-string elements (optional)
					// You could log an error or return an error from the function
					return nil, fmt.Errorf("Unexpected type in logo map: %v", item)
				}
			}
			convertedLogo[key] = stringSlice
		default:
			// Handle unexpected types (optional)
			// You could log an error or return an error from the function
			return nil, fmt.Errorf("Unexpected type in logo map: %v", value)
		}
	}
	return convertedLogo, nil
}

// create binary data from proto
func CreateBinaryFile(name string, data protoreflect.ProtoMessage) error {
	b, err := proto.Marshal(data)
	if err != nil {
		return err
	}

	fileName := fmt.Sprintf("%s.bin", name)
	if err := os.WriteFile(fileName, b, 0644); err != nil {
		return err
	}
	return nil
}
