package internalsdk

import (
	"bytes"
	cryptoRand "crypto/rand"
	"encoding/binary"
	"fmt"
	"math"
	"math/big"
	"strconv"
	"strings"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/lantern-client/internalsdk/protos"
	"github.com/getlantern/pathdb"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}

// Create Purchase Request
func createPurchaseData(session *SessionModel, email string, paymentProvider string, resellerCode string, purchaseToken string, planId string) (error, map[string]interface{}) {
	if email == "" {
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
		data["plan"] = planId
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
