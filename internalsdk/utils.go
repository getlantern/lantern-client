package internalsdk

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"math"
)

// Convered value in type that supprt minisql values
func convertValueToSupportedTypes(rawValue interface{}) interface{} {
	switch v := rawValue.(type) {
	case int64:
		return int(v)
	case int32:
		return int(v)
	case int16:
		return int(v)
	case int8:
		return int(v)
	default:
		return rawValue
	}
}

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, fmt.Errorf("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}

type Lang struct {
	Lang string `json:"lang"`
}

func extractLangValueFromJSON(localStr string) (string, error) {
	var langObj Lang
	err := json.Unmarshal([]byte(localStr), &langObj)
	if err != nil {
		return "", err
	}
	if langObj.Lang == "" {
		return "", fmt.Errorf("lang value not found")
	}
	return langObj.Lang, nil
}

type ReportIssue struct {
	Email       string `json:"email"`
	Issue       string `json:"issue"`
	Description string `json:"description"`
}

func extractReportValueFromJSON(reportJson string) (ReportIssue, error) {
	var reportIssue ReportIssue
	err := json.Unmarshal([]byte(reportJson), &reportIssue)
	if err != nil {
		return reportIssue, err
	}
	return reportIssue, nil
}
