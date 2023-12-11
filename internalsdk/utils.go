package internalsdk

import (
	"encoding/binary"
	"fmt"
	"math"
	"strconv"
	"strings"
	"time"

	"github.com/bojanz/currency"
	"github.com/getlantern/android-lantern/internalsdk/apimodels"
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
