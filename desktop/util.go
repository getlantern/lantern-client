package main

import "C"

import "encoding/json"

func sendJson(resp any) *C.char {
	b, _ := json.Marshal(resp)
	return C.CString(string(b))
}

func sendError(err error) *C.char {
	if err == nil {
		return C.CString("")
	}
	return sendJson(map[string]interface{}{
		"error": err.Error(),
	})
}

func booltoCString(value bool) *C.char {
	if value {
		return C.CString(string("true"))
	}
	return C.CString(string("false"))
}
