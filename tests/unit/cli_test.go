package unit_test

import (
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestCLIParseFlags validates that ParseFlags correctly maps all flag
// combinations to a ClusterConfig.
func TestCLIParseFlags(t *testing.T) {
	tests := []struct {
		name    string
		args    []string
		want    kindcluster.ClusterConfig
		wantErr bool
		errMsg  string
	}{
		{
			name: "defaults when no flags",
			args: nil,
			want: kindcluster.ClusterConfig{
				ClusterName:   kindcluster.DefaultClusterName,
				ControlPlanes: kindcluster.DefaultControlPlanes,
				Workers:       kindcluster.DefaultWorkers,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
		},
		{
			name: "custom cluster name",
			args: []string{"--cluster-name=my-cluster"},
			want: kindcluster.ClusterConfig{
				ClusterName:   "my-cluster",
				ControlPlanes: kindcluster.DefaultControlPlanes,
				Workers:       kindcluster.DefaultWorkers,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
		},
		{
			name: "HA configuration",
			args: []string{"--control-planes=3", "--workers=3"},
			want: kindcluster.ClusterConfig{
				ClusterName:   kindcluster.DefaultClusterName,
				ControlPlanes: 3,
				Workers:       3,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
		},
		{
			name: "zero workers allowed",
			args: []string{"--workers=0"},
			want: kindcluster.ClusterConfig{
				ClusterName:   kindcluster.DefaultClusterName,
				ControlPlanes: kindcluster.DefaultControlPlanes,
				Workers:       0,
				PodCIDR:       kindcluster.DefaultPodCIDR,
			},
		},
		{
			name:    "control-planes zero is invalid",
			args:    []string{"--control-planes=0"},
			wantErr: true,
			errMsg:  "--control-planes must be ≥ 1",
		},
		{
			name:    "negative workers is invalid",
			args:    []string{"--workers=-1"},
			wantErr: true,
			errMsg:  "--workers must be ≥ 0",
		},
		{
			name:    "uppercase cluster name rejected",
			args:    []string{"--cluster-name=My-Cluster"},
			wantErr: true,
			errMsg:  "DNS-1123",
		},
		{
			name:    "cluster name with trailing hyphen rejected",
			args:    []string{"--cluster-name=bad-"},
			wantErr: true,
			errMsg:  "DNS-1123",
		},
		{
			name:    "empty cluster name rejected",
			args:    []string{"--cluster-name="},
			wantErr: true,
			errMsg:  "must not be empty",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := kindcluster.ParseFlags(tc.args)
			if tc.wantErr {
				require.Error(t, err)
				assert.Contains(t, err.Error(), tc.errMsg)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tc.want, got)
		})
	}
}

// TestCLIValidateClusterName exercises ValidateClusterName directly.
func TestCLIValidateClusterName(t *testing.T) {
	tests := []struct {
		name    string
		input   string
		wantErr bool
	}{
		{"single char", "a", false},
		{"valid name", "heritage", false},
		{"hyphens in middle", "my-cluster-01", false},
		{"63 chars", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", false},
		{"empty", "", true},
		{"64 chars too long", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", true},
		{"leading hyphen", "-bad", true},
		{"trailing hyphen", "bad-", true},
		{"uppercase", "Heritage", true},
		{"spaces", "my cluster", true},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			err := kindcluster.ValidateClusterName(tc.input)
			if tc.wantErr {
				assert.Error(t, err)
			} else {
				assert.NoError(t, err)
			}
		})
	}
}
