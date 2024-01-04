package internalsdk

import (
	"encoding/binary"
	"math"

	"github.com/getlantern/errors"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
}
