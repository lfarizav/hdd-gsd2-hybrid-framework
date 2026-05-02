package kindcluster

import (
	"context"
	osExec "os/exec"
)

// Executor is the function signature used to run external commands.
// Injecting it at call sites makes provisioner and CNI logic fully testable
// without shelling out to a real binary.
type Executor func(ctx context.Context, name string, args ...string) ([]byte, error)

// RealExec is the production Executor backed by os/exec. It returns combined
// stdout+stderr so callers can include output in error messages.
func RealExec(ctx context.Context, name string, args ...string) ([]byte, error) {
	return osExec.CommandContext(ctx, name, args...).CombinedOutput()
}
