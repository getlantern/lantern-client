package internalsdk

import (
	"bytes"
	"crypto/rand"
	cryptoRand "crypto/rand"
	"encoding/binary"
	"fmt"
	"math"
	"math/big"
	"strconv"
	"strings"
	"time"

	"github.com/bojanz/currency"
	"github.com/getlantern/android-lantern/internalsdk/apimodels"
	"github.com/getlantern/android-lantern/internalsdk/protos"
	"github.com/getlantern/errors"
	"github.com/getlantern/pathdb"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}

func updatePrice(plan *apimodels.Plan, local string) error {
	bonous := plan.RenewalBonusExpected
	formattedBouns := formatRenewalBonusExpected(bonous.Months, bonous.Days, false)
	log.Debugf("updateprice formattedBouns %v", formattedBouns)
	totalCost, err := formatPrice(plan.Price, local)
	log.Debugf("updateprice Total cost %v", totalCost)
	if err != nil {
		return err
	}
	//One Month Price
	oneMonthCost, err := formatPrice(plan.ExpectedMonthlyPrice, local)
	if err != nil {
		return err
	}
	log.Debugf("updateprice oneMonthCost %v", oneMonthCost)
	var formattedDiscount string
	if plan.Discount > 0 {
		discountPercentage := math.Round(plan.Discount * 100)
		formattedDiscount = fmt.Sprintf("Save: %v%%", discountPercentage)
	}

	plan.TotalCostBilledOneTime = fmt.Sprintf("%v billed one time", totalCost)
	plan.OneMonthCost = oneMonthCost
	plan.FormattedBonus = formattedBouns
	plan.FormattedDiscount = formattedDiscount
	plan.TotalCost = totalCost
	return nil
}

func formatPrice(price map[string]int64, local string) (string, error) {
	locale := currency.NewLocale(local)
	formatter := currency.NewFormatter(locale)
	formatter.MaxDigits = 2

	for currencyCode, amount := range price {
		amountStr := fmt.Sprintf("%.2f", float64(amount)/100.00)
		log.Debugf("Amount is %v", amountStr)
		amount, err := currency.NewAmount(amountStr, strings.ToUpper(currencyCode))
		if err != nil {
			return "", err
		}
		log.Debugf("Formated price is %v", formatter.Format(amount))
		return strings.ToUpper(currencyCode) + formatter.Format(amount), nil
	}
	return "", nil
}

func formatRenewalBonusExpected(months int64, days int64, longForm bool) string {
	var bonusParts []string
	if months == 0 && days == 0 {
		return ""
	}
	if longForm {
		// "1 month and 15 days"
		if months > 0 {
			monthStr := "month"
			if months > 1 {
				monthStr = "months"
			}
			bonusParts = append(bonusParts, fmt.Sprintf("%d %s", months, monthStr))
		}
		if days > 0 {
			dayStr := "day"
			if days > 1 {
				dayStr = "days"
			}
			bonusParts = append(bonusParts, fmt.Sprintf("%d %s", days, dayStr))
		}
		return strings.Join(bonusParts, " and ")
	} else {
		totalDays := months*30 + days
		dayStr := "day"
		if totalDays > 1 {
			dayStr = "days"
		}
		return fmt.Sprintf("%d %s", totalDays, dayStr)
	}
}

//Create Purchase Request

func createPurchaseData(session *SessionModel, paymentProvider string, resellerCode string, purchaseToken string, planId string) (error, map[string]string) {
	email, err := session.Email()
	if err != nil {
		return err, nil
	}

	device, err := pathdb.Get[string](session.db, pathModel)
	if err != nil {
		return err, nil
	}

	data := map[string]string{
		"idempotencyKey": strconv.FormatInt(time.Now().UnixNano(), 10),
		"provider":       paymentProvider,
		"email":          email,
		"deviceName":     device,
	}

	switch paymentProvider {
	case paymentProviderResellerCode:
		data["provider"] = paymentProviderResellerCode
		data["resellerCode"] = resellerCode
		data["currency"] = "usd"
		data["plan"] = planId
	case paymentProviderApplePay:
		data["token"] = purchaseToken
		data["currency"] = "usd"
		data["plan"] = planId

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
		return nil, errors.New("failed to generate 8 byte salt")
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

func ConvertToUserDetailsResponse(userResponse *protos.LoginResponse) apimodels.UserDetailResponse {
	// Convert protobuf to usre details struct
	log.Debugf("ConvertToUserDetailsResponse %+v", userResponse)

	user := userResponse.LegacyUserData

	userData := apimodels.UserDetailResponse{
		UserID:       user.UserId,
		Code:         user.Code,
		Token:        userResponse.LegacyToken,
		Referral:     user.Code,
		UserLevel:    user.UserLevel,
		Expiration:   user.Expiration,
		Email:        user.Email,
		UserStatus:   user.UserStatus,
		Locale:       user.Locale,
		Servers:      user.Servers,
		YinbiEnabled: user.YinbiEnabled,
		Inviters:     user.Inviters,
		Invitees:     user.Invitees,
	}
	log.Debugf("ConvertToUserDetailsResponse %+v", userData)

	// Convert Purchases if needed
	for _, p := range user.Purchases {
		// Assuming you want to map the string directly to the Plan field of Purchase
		userData.Purchases = append(userData.Purchases, apimodels.Purchase{Plan: p})
	}

	for _, d := range user.Devices {
		// Map the fields from LoginResponse_Device to UserDevice
		userDevice := apimodels.UserDevice{
			ID:      d.GetId(),
			Name:    d.GetName(),
			Created: d.GetCreated(),
		}
		userData.Devices = append(userData.Devices, userDevice)
	}
	return userData
}
