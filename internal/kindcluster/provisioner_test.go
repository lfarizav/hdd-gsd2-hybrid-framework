package kindcluster_test

import (
	"bytes"
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// mockExec builds an Executor that returns preset (output, error) pairs in
// call order. Any call beyond the preset list returns (nil, nil).
func mockExec(responses ...struct {
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

func ok() struct{ out []byte; err error } {
	return struct{ out []byte; err error }{nil, nil}
}
func fail(msg string) struct{ out []byte; err error } {
	return struct{ out []byte; err error }{[]byte(msg), errors.New(msg)}
}

// ---------------------------------------------------------------------------
// TestKindConfigYAML — pure function, no mocking needed.
// ---------------------------------------------------------------------------

func TestKindConfigYAML(t *testing.T) {
	tests := []struct {
		name          string
		cfg           kindcluster.ClusterConfig
		wantSubstring []string
	}{
		{
			name: "single control-plane two workers",
			cfg: kindcluster.ClusterConfig{
				ClusterName:   "test",
				ControlPlanes: 1,
				Workers:       2,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
			wantSubstring: []string{
				"kind: Cluster",
				"apiVersion: kind.x-k8s.io/v1alpha4",
				"podSubnet:",
				"10.244.0.0/16",
				"role: control-plane",
				"role: worker",
			},
		},
		{
			name: "HA three control-planes",
			cfg: kindcluster.ClusterConfig{
				ClusterName:   "ha-cluster",
				ControlPlanes: 3,
				Workers:       0,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
			wantSubstring: []string{"role: control-plane"},
		},
		{
			name: "custom pod CIDR",
			cfg: kindcluster.ClusterConfig{
				ControlPlanes: 1,
				Workers:       1,
				PodCIDR:       "192.168.0.0/16",
			},
			wantSubstring: []string{"192.168.0.0/16"},
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got := kindcluster.KindConfigYAML(tc.cfg)
			require.NotEmpty(t, got)
			for _, want := range tc.wantSubstring {
				assert.True(t, strings.Contains(got, want),
					"expected YAML to contain %q\ngot:\n%s", want, got)
			}
		})
	}
}

// HA config should have exactly 3 control-plane entries.
func TestKindConfigYAML_ControlPlaneCount(t *testing.T) {
	cfg := kindcluster.ClusterConfig{ControlPlanes: 3, Workers: 2, PodCIDR: kindcluster.DefaultPodCIDR}
	yaml := kindcluster.KindConfigYAML(cfg)
	assert.Equal(t, 3, bytes.Count([]byte(yaml), []byte("role: control-plane")))
	assert.Equal(t, 2, bytes.Count([]byte(yaml), []byte("role: worker")))
}

// ---------------------------------------------------------------------------
// TestCreateCluster — mocked executor.
// ---------------------------------------------------------------------------

func TestCreateCluster(t *testing.T) {
	validCfg := kindcluster.ClusterConfig{
		ClusterName:   "heritage",
		ControlPlanes: 1,
		Workers:       2,
		PodCIDR:       kindcluster.DefaultPodCIDR,
	}

	tests := []struct {
		name      string
		cfg       kindcluster.ClusterConfig
		exec      kindcluster.Executor
		wantErr   bool
		errTarget error
		errMsg    string
	}{
		{
			name:    "happy path — kind returns success",
			cfg:     validCfg,
			exec:    mockExec(ok()),
			wantErr: false,
		},
		{
			name:      "cluster already exists",
			cfg:       validCfg,
			exec:      mockExec(fail("node(s) already exist for a cluster with the name \"heritage\"")),
			wantErr:   true,
			errTarget: kindcluster.ErrClusterExists,
		},
		{
			name:    "kind not installed",
			cfg:     validCfg,
			exec:    mockExec(fail("exec: no such file or directory: kind")),
			wantErr: true,
			errMsg:  "kind create cluster",
		},
		{
			name:    "kind returns generic error",
			cfg:     validCfg,
			exec:    mockExec(fail("failed to create cluster: timed out")),
			wantErr: true,
			errMsg:  "kind create cluster",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			err := kindcluster.CreateCluster(context.Background(), tc.cfg, tc.exec)
			if !tc.wantErr {
				require.NoError(t, err)
				return
			}
			require.Error(t, err)
			if tc.errTarget != nil {
				assert.True(t, errors.Is(err, tc.errTarget),
					"expected errors.Is(err, %v), got: %v", tc.errTarget, err)
			}
			if tc.errMsg != "" {
				assert.Contains(t, err.Error(), tc.errMsg)
			}
		})
	}
}
