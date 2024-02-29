package app

import (
	"io/ioutil"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestTLInstallFailuresFile(t *testing.T) {
	f, err := ioutil.TempFile("", "flashlight-TestTLInstallFailuresFile")
	require.NoError(t, err)
	defer os.Remove(f.Name())
	f.Close()

	failuresFile, err := openTLInstallFailuresFile(f.Name())
	require.NoError(t, err)
	require.True(t, failuresFile.LastDenial.IsZero())
	require.True(t, failuresFile.LastFailed.IsZero())
	require.Zero(t, failuresFile.Denials)

	failuresFile.Denials++
	failuresFile.LastDenial = yamlableNow()
	require.NoError(t, failuresFile.flushChanges())

	failuresFile2, err := openTLInstallFailuresFile(f.Name())
	require.NoError(t, err)
	require.True(t, failuresFile2.LastFailed.IsZero())
	require.Equal(t, failuresFile.Denials, failuresFile2.Denials)
	require.Equal(t,
		time.Time(*failuresFile.LastDenial).Format(yamlableTimeFormat),
		time.Time(*failuresFile2.LastDenial).Format(yamlableTimeFormat),
	)
}
