package deviceid

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestGet(t *testing.T) {
	id1 := Get()
	require.True(t, len(id1) > 8)
	id2 := Get()
	require.Equal(t, id1, id2)
}
