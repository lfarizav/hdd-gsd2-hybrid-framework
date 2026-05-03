package kindcluster
package kindcluster_test

import (
	"context"
	"errors"
	"os"
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// seqMock builds an Executor whose responses follow the given sequence.
// Calls beyond the list succeed silently.
func seqMock(responses ...struct {
	out []byte
	err error
}) kindcluster.Executor {
	idx := 0
	return func(_ context.Context, _ string, _ ...string) ([]byte, error) {
		if idx >= len(responses) {
			return nil, nil
		}
		r := responses[idx]
		idx++
		return r.out, r.err
	}
}

func cniOK() struct{ out []byte; err error } {
	return struct{ out []byte; err error }{nil, nil}
}
func cniFail(msg string) struct{ out []byte; err error } {
	return struct{ out []byte; err error }{[]byte(msg), errors.New(msg)}
}

// tempKubeconfig creates an empty temp file to act as a kubeconfig placeholder.
// Returns the path and a cleanup func.
func tempKubeconfig(t *testing.T) string {
	t.Helper()
	f, err := os.CreateTemp("", "kubeconfig-*.yaml")
	require.NoError(t, err)
	f.Close()
	t.Cleanup(func() { os.Remove(f.Name()) })
	return f.Name()
}

// ---------------------------------------------------------------------------
// TestInstallCalicoNS — all branches exercised.
// ---------------------------------------------------------------------------

func TestInstallCalicoNS(t *testing.T) {
	tests := []struct {
		name       string
		kubeconfig string
		exec       kindcluster.Executor
		wantErr    bool
		errMsg     string
	}{
		{
			name: "happy path",
			// kubeconfig is set per-test below
			exec:    seqMock(cniOK(), cniOK(), cniOK(), cniOK()),
			wantErr: false,
		},
		{
			name:       "kubectl not found",
			kubeconfig: "/does-not-matter",
			exec:       seqMock(cniFail("exec: no such file or directory: kubectl")),
			wantErr:    true,
			errMsg:     "kubectl not found",
		},
		{
			name:       "kubeconfig does not exist",
			kubeconfig: "/nonexistent/kubeconfig-xyz.yaml",
			exec:       seqMock(cniOK()), // kubectl version succeeds
			wantErr:    true,
			errMsg:     "kubeconfig",
		},
		{
			name:    "operator manifest apply fails",
			exec:    seqMock(cniOK(), cniFail("error: failed to create")),
			wantErr: true,
			errMsg:  "Calico operator",
		},
		{
			name:    "custom-resources apply fails",
			exec:    seqMock(cniOK(), cniOK(), cniFail("error: custom resources failed")),
			wantErr: true,
			errMsg:  "Calico custom resources",
		},
		{
			name:    "pods do not become ready",
			exec:    seqMock(cniOK(), cniOK(), cniOK(), cniFail("timed out waiting")),
			wantErr: true,
			errMsg:  "Calico pods not ready",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			kc := tc.kubeconfig
			// For tests that don't set kubeconfig, create a real temp file so
			// os.Stat passes and we can exercise the exec-level errors.
			if kc == "" {
				kc = tempKubeconfig(t)
			}

			err := kindcluster.InstallCalicoNS(context.Background(), kc, "test-cluster", tc.exec)
			if !tc.wantErr {
				require.NoError(t, err)
				return
			}
			require.Error(t, err)
			if tc.errMsg != "" {
				assert.Contains(t, err.Error(), tc.errMsg)
			}
		})
	}
}
