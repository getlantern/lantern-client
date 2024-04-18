//go:build !ios

package common

import "runtime"

const Platform = runtime.GOOS
