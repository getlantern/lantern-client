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

	"github.com/getlantern/errors"
)

func BytesToFloat64LittleEndian(b []byte) (float64, error) {
	if len(b) != 8 {
		return 0, errors.New("expected 8 bytes but got %d", len(b))
	}
	bits := binary.LittleEndian.Uint64(b)
	return math.Float64frombits(bits), nil
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
	salt := make([]byte, 8)
	if n, err := rand.Read(salt); err != nil {
		return nil, err
	} else if n != 8 {
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
