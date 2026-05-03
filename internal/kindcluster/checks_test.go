package kindcluster
package kindcluster_test

import (
	"context"
	"errors"
	"testing"

	"github.com/lfarizav/heritage/internal/kindcluster"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestClusterExists(t *testing.T) {
	tests := []struct {
		name        string
		clusterName string
		output      string
		execErr     error
		want        bool
		wantErr     bool
	}{
		{
			name:        "cluster is listed",
			clusterName: "heritage",
			output:      "heritage\nother-cluster\n",
			want:        true,
		},
		{
			name:        "cluster not in list",
			clusterName: "heritage",
			output:      "other-cluster\n",
			want:        false,
		},
		{
			name:        "empty list",
			clusterName: "heritage",
			output:      "",
			want:        false,
		},
		{
			name:        "kind get clusters fails",
			clusterName: "heritage",
			execErr:     errors.New("kind: not found"),
			wantErr:     true,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			exec := func(_ context.Context, _ string, _ ...string) ([]byte, error) {
				return []byte(tc.output), tc.execErr
			}
			got, err := kindcluster.ClusterExists(context.Background(), tc.clusterName, exec)
			if tc.wantErr {
				require.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tc.want, got)
		})
	}
}

func TestDeleteCluster(t *testing.T) {
	t.Run("delete succeeds", func(t *testing.T) {
		exec := func(_ context.Context, _ string, _ ...string) ([]byte, error) {
			return nil, nil
		}
		require.NoError(t, kindcluster.DeleteCluster(context.Background(), "heritage", exec))
	})

	t.Run("delete fails", func(t *testing.T) {
		exec := func(_ context.Context, _ string, _ ...string) ([]byte, error) {
			return []byte("no such cluster"), errors.New("cluster not found")
		}
		err := kindcluster.DeleteCluster(context.Background(), "heritage", exec)
		require.Error(t, err)
		assert.Contains(t, err.Error(), "kind delete cluster")
	})
}
