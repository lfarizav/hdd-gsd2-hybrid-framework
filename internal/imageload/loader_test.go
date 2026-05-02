package imageload_test

import (
	"archive/tar"
	"compress/gzip"
	"context"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/lfarizav/heritage/internal/imageload"
	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// ---- helpers ---------------------------------------------------------------

func execOK() kindcluster.Executor {
	return func(_ context.Context, _ string, _ ...string) ([]byte, error) {
		return nil, nil
	}
}

func execFail(msg string) kindcluster.Executor {
	return func(_ context.Context, _ string, _ ...string) ([]byte, error) {
		return []byte(msg), errors.New(msg)
	}
}

// writeTarGZ creates a valid gzipped tar archive containing one empty file.
func writeTarGZ(t *testing.T, path string) {
	t.Helper()
	f, err := os.Create(path)
	require.NoError(t, err)
	defer f.Close()

	gz := gzip.NewWriter(f)
	tw := tar.NewWriter(gz)
	require.NoError(t, tw.WriteHeader(&tar.Header{Name: "image.json", Size: 0}))
	require.NoError(t, tw.Close())
	require.NoError(t, gz.Close())
}

// writePlainTar creates a valid (non-compressed) tar archive.
func writePlainTar(t *testing.T, path string) {
	t.Helper()
	f, err := os.Create(path)
	require.NoError(t, err)
	defer f.Close()

	tw := tar.NewWriter(f)
	require.NoError(t, tw.WriteHeader(&tar.Header{Name: "image.json", Size: 0}))
	require.NoError(t, tw.Close())
}

// ---- TestLoadImagesFromArchive ---------------------------------------------

func TestLoadImagesFromArchive(t *testing.T) {
	dir := t.TempDir()

	t.Run("happy path — gzipped tar", func(t *testing.T) {
		archive := filepath.Join(dir, "image.tar.gz")
		writeTarGZ(t, archive)

		err := imageload.LoadImagesFromArchive(context.Background(), archive, "test-cluster", execOK())
		require.NoError(t, err)
	})

	t.Run("happy path — plain tar", func(t *testing.T) {
		archive := filepath.Join(dir, "image.tar")
		writePlainTar(t, archive)

		err := imageload.LoadImagesFromArchive(context.Background(), archive, "test-cluster", execOK())
		require.NoError(t, err)
	})

	t.Run("archive does not exist", func(t *testing.T) {
		err := imageload.LoadImagesFromArchive(context.Background(), "/nonexistent/image.tar", "test-cluster", execOK())
		require.Error(t, err)
		assert.Contains(t, err.Error(), "archive not found")
	})

	t.Run("corrupt archive", func(t *testing.T) {
		corrupt := filepath.Join(dir, "corrupt.tar.gz")
		require.NoError(t, os.WriteFile(corrupt, []byte("not a tar"), 0o600))

		err := imageload.LoadImagesFromArchive(context.Background(), corrupt, "test-cluster", execOK())
		require.Error(t, err)
	})

	t.Run("kind load fails", func(t *testing.T) {
		archive := filepath.Join(dir, "fail.tar.gz")
		writeTarGZ(t, archive)

		err := imageload.LoadImagesFromArchive(context.Background(), archive, "test-cluster",
			execFail("kind: connection refused"))
		require.Error(t, err)
		assert.Contains(t, err.Error(), "kind load image-archive")
	})

	t.Run("path is a directory", func(t *testing.T) {
		err := imageload.LoadImagesFromArchive(context.Background(), dir, "test-cluster", execOK())
		require.Error(t, err)
		assert.Contains(t, err.Error(), "is a directory")
	})
}

// ---- TestListArchives ------------------------------------------------------

func TestListArchives(t *testing.T) {
	dir := t.TempDir()
	writeTarGZ(t, filepath.Join(dir, "a.tar.gz"))
	writePlainTar(t, filepath.Join(dir, "b.tar"))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "readme.txt"), []byte("ignore"), 0o600))

	archives, err := imageload.ListArchives(dir)
	require.NoError(t, err)
	assert.Len(t, archives, 2)

	t.Run("nonexistent directory", func(t *testing.T) {
		_, err := imageload.ListArchives("/nonexistent/dir")
		require.Error(t, err)
	})
}
