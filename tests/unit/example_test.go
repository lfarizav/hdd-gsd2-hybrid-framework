package unit_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestModuleSetup validates that the Go module is correctly initialised and
// that testify is available. It uses table-driven subtests per the project
// conventions recorded in KNOWLEDGE.md.
func TestModuleSetup(t *testing.T) {
	tests := []struct {
		name  string
		input string
		want  string
	}{
		{name: "non-empty string is unchanged", input: "hello", want: "hello"},
		{name: "empty string remains empty", input: "", want: ""},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			require.NotNil(t, tc.input, "input must not be nil")
			assert.Equal(t, tc.want, tc.input)
		})
	}
}
