package apimodels

import (
	"strconv"
	"unicode"
)

func StringToIntSlice(str string) ([]int, error) {
	log.Debugf("StringToIntSlice: %s", str)
	var slice []int

	for _, char := range str {
		if unicode.IsDigit(char) {
			digit, err := strconv.Atoi(string(char))
			if err != nil {
				return nil, err
			}
			slice = append(slice, digit)
		}
	}

	return slice, nil
}
