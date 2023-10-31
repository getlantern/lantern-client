package internalsdk

import (
	"encoding/binary"
	"fmt"
	"math"
	"strings"

	"github.com/bojanz/currency"
	"github.com/getlantern/errors"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}

func updatePrice() {
	// formattedBouns := formatRenewalBonusExpected()

}

func formatRenewalBonusExpected(planBonus int64, days int64, longForm bool) string {
	var bonusParts []string
	if planBonus == 0 && days == 0 {
		return ""
	}
	if longForm {
		// "1 month and 15 days"
		if planBonus > 0 {
			monthStr := "month"
			if planBonus > 1 {
				monthStr = "months"
			}
			bonusParts = append(bonusParts, fmt.Sprintf("%d %s", planBonus, monthStr))
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
		totalDays := planBonus*30 + days
		dayStr := "day"
		if totalDays > 1 {
			dayStr = "days"
		}
		return fmt.Sprintf("%d %s", totalDays, dayStr)
	}
}

func getSymbol(currencyCode string) (string, error) {
	locale := currency.NewAmount()
	formatter := currency.GetCurrencyCodes()

	currency.NewAmount("8", currency.GetSymbol())

	if err != nil {
		return "", err // handle error
	}
	return unit.Symbol(), nil
}
