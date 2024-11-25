package main

import "C"

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
)

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

// createDirIfNotExists checks that a directory exists, creating it if necessary
func createDirIfNotExists(dir string, perm os.FileMode) error {
	if _, err := os.Stat(dir); err != nil {
		if os.IsNotExist(err) {
			return os.MkdirAll(dir, perm)
		}
		return err
	}
	return nil
}

// startPprof starts a pprof server at the given address
func startPprof(addr string) {
	log.Debugf("Starting pprof server at %s (http://%s/debug/pprof)", addr)
	srv := &http.Server{Addr: addr}
	if err := srv.ListenAndServe(); err != nil {
		log.Errorf("Error starting pprof server: %v", err)
	}
}

// create binary data from proto
func CreateBinaryFile(name string, data protoreflect.ProtoMessage) error {
	b, err := proto.Marshal(data)
	if err != nil {
		return err
	}

	fileName := fmt.Sprintf("%s.bin", name)
	if err := os.WriteFile(fileName, b, 0644); err != nil {
		return err
	}
	return nil
}
