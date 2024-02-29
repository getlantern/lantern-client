package internalsdk

import (
	"io"
	"path/filepath"
	"sync"
	"time"

	"github.com/getlantern/errors"
	"github.com/getlantern/golog"
	"github.com/getlantern/lantern-client/internalsdk/ios/logger"
)

const (
	logMemoryInterval = 5 * time.Second
	forceGCInterval   = 250 * time.Millisecond

	dialTimeout      = 30 * time.Second
	shortIdleTimeout = 5 * time.Second
	closeTimeout     = 1 * time.Second

	ipWriteBufferDepth = 100
)

var (
	statsLog = golog.LoggerFor("ios.stats")
	swiftLog = golog.LoggerFor("ios.swift")
)

type Writer interface {
	Write([]byte) bool
}

type writeRequest struct {
	b  []byte
	ok chan bool
}

type writerAdapter struct {
	writer    Writer
	requests  chan *writeRequest
	closeOnce sync.Once
}

func newWriterAdapter(writer Writer) io.WriteCloser {
	wa := &writerAdapter{
		writer:   writer,
		requests: make(chan *writeRequest, ipWriteBufferDepth),
	}

	// MEMORY_OPTIMIZATION - handle all writing of output packets on a single goroutine to avoid creating more native threads
	go wa.handleWrites()
	return wa
}

func (wa *writerAdapter) Write(b []byte) (int, error) {
	req := &writeRequest{
		b:  b,
		ok: make(chan bool),
	}
	wa.requests <- req
	ok := <-req.ok
	if !ok {
		return 0, errors.New("error writing")
	}
	return len(b), nil
}

func (wa *writerAdapter) handleWrites() {
	for req := range wa.requests {
		req.ok <- wa.writer.Write(req.b)
	}
}

func (wa *writerAdapter) Close() error {
	wa.closeOnce.Do(func() {
		close(wa.requests)
	})
	return nil
}

type ClientWriter interface {
	// Write writes the given bytes. As a side effect of writing, we periodically
	// record updated bandwidth quota information in the configured quota.txt file.
	// If user has exceeded bandwidth allowance, returns a positive integer
	// representing the bandwidth allowance.
	Write([]byte) (int, error)

	// Reconfigure forces the ClientWriter to update its configuration
	Reconfigure()

	Close() error
}

type cw struct {
	client         *iosClient
	quotaTextPath  string
	lastSavedQuota time.Time
}

func (c *cw) Write(b []byte) (int, error) {
	return 0, nil
}

func (c *cw) Reconfigure() {

}

func (c *cw) Close() error {
	if c.client != nil {
		c.client.packetsOut.Close()
	}
	return nil
}

type iosClient struct {
	packetsOut      io.WriteCloser
	memChecker      MemChecker
	configDir       string
	mtu             int
	capturedDNSHost string
	realDNSHost     string
	clientWriter    *cw
	memoryAvailable int64
	started         time.Time
}

func Client(packetsOut Writer, memChecker MemChecker, configDir string, mtu int, capturedDNSHost, realDNSHost string) (ClientWriter, error) {
	log.Debug("Creating new iOS client")
	if mtu <= 0 {
		log.Debug("Defaulting MTU to 1500")
		mtu = 1500
	}

	c := &iosClient{
		packetsOut:      newWriterAdapter(packetsOut),
		memChecker:      memChecker,
		configDir:       configDir,
		mtu:             mtu,
		capturedDNSHost: capturedDNSHost,
		realDNSHost:     realDNSHost,
		started:         time.Now(),
	}

	return c.start()
}

func (c *iosClient) start() (ClientWriter, error) {
	c.clientWriter = &cw{
		client:        c,
		quotaTextPath: filepath.Join(c.configDir, "quota.txt"),
	}
	return c.clientWriter, nil
}

// ConfigureFileLogging configures logging to log to files at the given fullLogFilePath
// and capture heap and goroutine profiles at the given profile path.
func ConfigureFileLogging(fullLogFilePath string, profilePath string) error {
	SetProfilePath(profilePath)
	return logger.ConfigureFileLogging(fullLogFilePath)
}

// LogDebug logs the given msg to the swift logger at debug level
func LogDebug(msg string) {
	swiftLog.Debug(msg)
}

// LogError logs the given msg to the swift logger at error level
func LogError(msg string) {
	swiftLog.Error(msg)
}
