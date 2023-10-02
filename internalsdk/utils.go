package internalsdk

import (
	"encoding/binary"
	"encoding/json"
	"fmt"
	"math"

	"github.com/getlantern/pathdb"
	"github.com/getlantern/pathdb/minisql"
)

// PutKeysFromJSON initializes key-value pairs in the database from a JSON-formatted string.
// The JSON should contain keys mapped to an object containing the type and the value.
//
// Example JSON format:
//
//	{
//	   "developmentMode": {"type": "bool", "value": true},
//	   "lang": {"type": "string", "value": "en"}
//	}
//
// Parameters:
// - jsonString: The JSON-formatted string containing the initialization data.
// - db: The database instance where the data will be stored.
//
// Returns:
// - error: nil if successful, otherwise the error that occurred.
func putFromJson(jsonString string, db pathdb.DB) error {
	// Deserialize the JSON string into a map
	log.Debugf("Json String go %v", jsonString)
	var initData map[string]map[string]interface{}
	if err := json.Unmarshal([]byte(jsonString), &initData); err != nil {
		return err
	}
	log.Debugf("Init data %v", initData)
	// Loop over the map to populate your database
	return pathdb.Mutate(db, func(tx pathdb.TX) error {
		for key, valueData := range initData {
			var valueType int
			if floatValue, ok := valueData["type"].(float64); ok {
				valueType = int(floatValue)
			} else {
				return log.Errorf("Missing or invalid type for key %s", key)
			}
			value, ok := valueData["value"]
			if !ok {
				return log.Errorf("Missing value for key %s", key)
			}

			switch valueType {
			case minisql.ValueTypeBool:
				// Convert value to bool and put it
				actualValue, ok := value.(bool)
				if !ok {
					return log.Errorf("Invalid value for type bool: %v", value)
				}
				pathdb.Put[bool](tx, key, actualValue, "")

			case minisql.ValueTypeString:
				// Convert value to string and put it
				actualValue, ok := value.(string)
				if !ok {
					return log.Errorf("Invalid value for type string: %v", value)
				}

				if key == "lang" {
					// Check if lang is already added or not
					lang, err := pathdb.Get[string](tx, LANG)
					if err != nil {
						return err
					}
					if lang != "" {
						pathdb.Put[string](tx, key, lang, "")
					} else {
						pathdb.Put[string](tx, key, actualValue, "")
					}
				} else {
					pathdb.Put[string](tx, key, actualValue, "")
				}

			case minisql.ValueTypeInt:
				// Convert value to string and put it
				actualValue, ok := value.(int)
				if !ok {
					return log.Errorf("Invalid value for type int: %v", value)
				}
				pathdb.Put[int](tx, key, actualValue, "")
			case minisql.ValueTypeBytes:
				// Convert value to string and put it
				actualValue, ok := value.(byte)
				if !ok {
					return log.Errorf("Invalid value for type bytes: %v", value)
				}
				pathdb.Put[byte](tx, key, actualValue, "")

			default:
				return log.Errorf("Unsupported type: %s", valueType)
			}
		}

		return nil
	})
}

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
