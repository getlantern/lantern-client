package server

import (
	"net/http"
)

// PathHandler contains a request path pattern and an HTTP handler for that
// pattern.
type PathHandler struct {
	Pattern string
	Handler http.Handler
}