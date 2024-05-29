package ios

import (
	"errors"
	"net"
	"runtime"
	"sync"

	"github.com/eycorsican/go-tun2socks/core"

	"github.com/getlantern/safechannels"
)

var (
	errWriteOnClosedConn = errors.New("write on closed threadLimitingTCPConn")
)

type worker struct {
	tasks chan func()
}

func newWorker(bufferDepth int) *worker {
	w := &worker{
		tasks: make(chan func(), bufferDepth),
	}
	go w.work()
	return w
}

func (w *worker) work() {
	// MEMORY_OPTIMIZATION - locking to the OS thread seems to help keep Go from spawning more OS threads when cgo calls are blocked
	runtime.LockOSThread()

	for task := range w.tasks {
		task()
	}
}

type threadLimitingTCPConn struct {
	net.Conn
	writeWorker *worker
	writeResult safechannels.IO
	closeOnce   sync.Once
}

func newThreadLimitingTCPConn(wrapped net.Conn, writeWorker *worker) net.Conn {
	return &threadLimitingTCPConn{
		Conn:        wrapped,
		writeWorker: writeWorker,
		writeResult: safechannels.NewIO(1),
	}
}

func (c *threadLimitingTCPConn) Write(b []byte) (int, error) {
	c.writeWorker.tasks <- func() {
		c.writeResult.Write(c.Conn.Write(b))
	}
	result, ok := <-c.writeResult.Read()
	if !ok {
		return 0, errWriteOnClosedConn
	}
	return result.N, result.Err
}

func (c *threadLimitingTCPConn) Close() (err error) {
	c.closeOnce.Do(func() {
		c.writeResult.Close()
		err = c.Conn.Close()
	})
	return
}

// Wrapped implements the interface netx.WrappedConn
func (c *threadLimitingTCPConn) Wrapped() net.Conn {
	return c.Conn
}

type threadLimitingUDPConn struct {
	core.UDPConn
	writeWorker *worker
}

func newThreadLimitingUDPConn(wrapped core.UDPConn, writeWorker *worker) core.UDPConn {
	return &threadLimitingUDPConn{
		UDPConn:     wrapped,
		writeWorker: writeWorker,
	}
}

func (c *threadLimitingUDPConn) WriteFrom(b []byte, addr *net.UDPAddr) (int, error) {
	writeResult := make(chan *safechannels.IOResult)
	c.writeWorker.tasks <- func() {
		n, err := c.UDPConn.WriteFrom(b, addr)
		writeResult <- &safechannels.IOResult{n, err}
	}
	result := <-writeResult
	return result.N, result.Err
}
