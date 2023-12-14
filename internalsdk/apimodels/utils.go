package apimodels

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"
	"strings"
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

func RequestToCurl(req *http.Request) (string, error) {
	if req == nil {
		return "", fmt.Errorf("request is nil")
	}

	var curlCommand strings.Builder

	curlCommand.WriteString("curl -X ")
	curlCommand.WriteString(req.Method)
	curlCommand.WriteString(" '")
	curlCommand.WriteString(req.URL.String())
	curlCommand.WriteString("'")

	// Adding headers to the cURL command
	for headerName, headerValues := range req.Header {
		for _, headerValue := range headerValues {
			curlCommand.WriteString(fmt.Sprintf(" -H '%s: %s'", headerName, headerValue))
		}
	}

	// Adding body if present
	if req.Body != nil {
		bodyBytes, err := ioutil.ReadAll(req.Body)
		if err != nil {
			return "", fmt.Errorf("error reading request body: %w", err)
		}
		// Reset the request body so it can be used again
		req.Body = ioutil.NopCloser(bytes.NewBuffer(bodyBytes))

		bodyStr := string(bodyBytes)
		if bodyStr != "" {
			// Use -d to add the body
			curlCommand.WriteString(fmt.Sprintf(" -d '%s'", bodyStr))
		}
	}

	return curlCommand.String(), nil
}
