package internalsdk

import (
	"crypto/rand"
	cryptoRand "crypto/rand"
	"encoding/binary"
	"math"
	"math/big"

	"github.com/getlantern/errors"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
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
	salt := make([]byte, 8)
	if n, err := rand.Read(salt); err != nil {
		return nil, err
	} else if n != 8 {
		return nil, errors.New("failed to generate 8 byte salt")
	}
	return salt, nil
}
