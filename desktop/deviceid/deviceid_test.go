package deviceid

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestGet(t *testing.T) {
	id1 := Get()
	require.True(t, len(id1) > 8)
	id2 := Get()
	require.Equal(t, id1, id2)

	tmpDir := filepath.Join(t.TempDir(), ".lanternsecrets")
	// Test no existing .deviceid
	deviceID1 := get(tmpDir)
	assert.NotEmpty(t, deviceID1, "Device ID should not be empty")
	assert.Len(t, deviceID1, 36, "Device ID should have 36 characters")
	assert.NoError(t, validateUUID(deviceID1), "Device ID should be a valid UUID")

	// Verify the .deviceid file was created
	deviceIDPath := filepath.Join(tmpDir, ".deviceid")
	assert.FileExists(t, deviceIDPath, ".deviceid file should be created")

	deviceID2 := get(tmpDir)
	assert.Equal(t, deviceID1, deviceID2, "Device ID should be the same across calls")

	// Check trimming of white space
	err := os.WriteFile(deviceIDPath, []byte(deviceID1+"\n"), 0644)
	assert.NoError(t, err, "Should write .deviceid without errors")
	deviceID3 := get(tmpDir)
	assert.Equal(t, deviceID1, deviceID3, "Device ID should trim white space")
}

// Helper to validate UUID string
func validateUUID(u string) error {
	_, err := uuid.Parse(u)
	return err
}
