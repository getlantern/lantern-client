package ios

import (
	"io"
	"net"
	"sync"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestThreadLimitingConn(t *testing.T) {
	const msg = "echo me"

	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)

	go func() {
		for {
			conn, err := l.Accept()
			if err == nil {
				go func() {
					io.Copy(conn, conn)
				}()
			}
		}
	}()

	worker := newWorker(1)

	readers := 100
	var wg sync.WaitGroup
	wg.Add(readers)
	for i := 0; i < readers; i++ {
		go func() {
			defer wg.Done()
			_conn, err := net.Dial("tcp", l.Addr().String())
			require.NoError(t, err)
			conn := newThreadLimitingTCPConn(_conn, worker)
			n, err := conn.Write([]byte(msg))
			require.Equal(t, n, len(msg))
			b := make([]byte, 1024)
			n, err = conn.Read(b)
			require.Equal(t, n, len(msg))
			require.Equal(t, msg, string(b[:n]))

			conn.Close()
			_, err = conn.Write([]byte("extra"))
			require.Equal(t, errWriteOnClosedConn, err)
		}()
	}

	wg.Wait()
}
