package internalsdk

import (
	"encoding/binary"
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
