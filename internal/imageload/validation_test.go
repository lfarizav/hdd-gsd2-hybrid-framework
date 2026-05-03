package imageload
package imageload_test

import (
	"context"
	"os"
	"path/filepath"
	"testing"

	"github.com/lfarizav/heritage/internal/imageload"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestValidateAirGap(t *testing.T) {
	// Build a temp dir with all required archives.
	dir := t.TempDir()
	for _, f := range imageload.RequiredImageFiles {
		require.NoError(t, os.WriteFile(filepath.Join(dir, f), []byte(""), 0o600))
	}

	tests := []struct {
		name      string
		imagesDir string
		envDir    string
		wantErr   bool
		errMsg    string
	}{
		{
			name:      "happy path — flag wins",
			imagesDir: dir,
			wantErr:   false,
		},
		{
			name:    "happy path — env var",
			envDir:  dir,
			wantErr: false,
		},
		{
			name:    "no flag and no env var",
			wantErr: true,
			errMsg:  "not specified",
		},
		{
			name:      "directory does not exist",
			imagesDir: "/nonexistent/images",
			wantErr:   true,
			errMsg:    "images directory",
		},
		{
			name:      "missing required archive",
			imagesDir: t.TempDir(), // empty dir
			wantErr:   true,
			errMsg:    "not found",
		},
		{
			name:      "path is a file not a directory",
			imagesDir: filepath.Join(dir, imageload.RequiredImageFiles[0]),
			wantErr:   true,
			errMsg:    "not a directory",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if tc.envDir != "" {
				t.Setenv("IMAGES_DIR", tc.envDir)
			} else {
				t.Setenv("IMAGES_DIR", "")
			}

			err := imageload.ValidateAirGap(context.Background(), tc.imagesDir)
			if tc.wantErr {
				require.Error(t, err)
				if tc.errMsg != "" {
					assert.Contains(t, err.Error(), tc.errMsg)
				}
				return
			}
			require.NoError(t, err)
		})
	}
}
