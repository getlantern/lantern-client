package ios

import (
	"os"
	"path/filepath"
	"sort"
	"strings"
	"testing"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/getlantern/flashlight/v7/common"
	"github.com/stretchr/testify/require"
)

const (
	testDeviceID1 = "test1"
	testDeviceID2 = "test2"
)

func TestConfigure(t *testing.T) {
	common.CompileTimeApplicationVersion = "8.0.0"
	common.LibraryVersion = "8.0.0"
	tmpDir, err := os.MkdirTemp("", "config_test")
	require.NoError(t, err)
	defer os.RemoveAll(tmpDir)

	os.WriteFile(filepath.Join(tmpDir, "global.yaml"), []byte{}, 0644)
	os.WriteFile(filepath.Join(tmpDir, "global.yaml.etag"), []byte{}, 0644)
	os.WriteFile(filepath.Join(tmpDir, "proxies.yaml"), []byte{}, 0644)
	os.WriteFile(filepath.Join(tmpDir, "proxies.yaml.etag"), []byte{}, 0644)
	os.WriteFile(filepath.Join(tmpDir, "masquerade_cache"), []byte{}, 0644)
	os.WriteFile(filepath.Join(tmpDir, "userconfig.yaml"), []byte{}, 0644)

	const testUserId = 83901
	const testToken = "testToken"
	result1, err := Configure(tmpDir, testUserId, testToken, testDeviceID1, true, "")
	require.NoError(t, err)

	require.True(t, result1.VPNNeedsReconfiguring)
	require.NotEmpty(t, result1.IPSToExcludeFromVPN)

	c := &configurer{configFolderPath: tmpDir}
	uc, err := c.readUserConfig()
	require.NoError(t, err)
	require.Equal(t, testDeviceID1, uc.GetDeviceID())

	time.Sleep(1 * time.Second)
	watcher, err := fsnotify.NewWatcher()
	require.NoError(t, err)
	err = watcher.Add(c.fullPathTo(userConfigYaml))
	require.NoError(t, err)
	result2, err := Configure(tmpDir, testUserId, testToken, testDeviceID2, true, "")
	require.NoError(t, err)
	ips1 := strings.Split(result1.IPSToExcludeFromVPN, ",")
	ips2 := strings.Split(result2.IPSToExcludeFromVPN, ",")
	sort.Strings(ips1)
	sort.Strings(ips2)
	if result2.VPNNeedsReconfiguring {
		require.NotEqual(t, ips1, ips2)
	} else {
		require.Equal(t, ips1, ips2)
	}

	// make sure the config file has been changed
	<-watcher.Events
	uc, err = c.readUserConfig()
	require.NoError(t, err)
	require.Equal(t, testDeviceID2, uc.GetDeviceID())
}
