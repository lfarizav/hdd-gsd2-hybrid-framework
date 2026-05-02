# GSD-2 Manual Execution Automation

> **For when GSD CLI is unavailable or API keys are missing.**
>
> This automation streamlines the repetitive task of manual GSD-2 execution by tracking task progress, displaying requirements, and running quality gates automatically.

---

## Quick Start

```bash
# From project root
bash gsd-manual

# Or source the routine for interactive use
source .gsd/manual-routine.sh
gsd_next_task
```

**What it does:**
1. ✅ Finds the next incomplete task from ROADMAP.md
2. 📋 Displays task requirements (must-haves, artifact, verification)
3. 🎯 Prompts you to complete the task
4. ✔️ Runs quality gates (go test, coverage, lint, build)
5. ✅ Marks task complete
6. 🔜 Suggests the next task

---

## How It Works

### Phase 1: Read Task Requirements

The script reads `.planning/ROADMAP.md` to find the first incomplete task. For each task, it displays:

- **Action:** What needs to be implemented
- **Must-Haves:** Required deliverables
- **Artifact:** File(s) to create/modify
- **Truth Test:** How to verify it works
- **Verify Command:** Exact command to run

Example output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Task Details: M001-S01-T02
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### M001-S01-T02: Go Module Setup

**Action:** Initialize Go module for `github.com/lfarizav/heritage`

**Must-Haves:**
1. `go.mod` created with module name `github.com/lfarizav/heritage`
2. Directory structure created: cmd/kind-cluster, internal/kindcluster, internal/imageload, tests/
3. Dependency pinned: `github.com/stretchr/testify` (latest from pkg.go.dev)
4. First test created: `tests/unit/example_test.go` with `TestMain()` + subtests
5. Verify: `go test ./... && go build ./cmd/kind-cluster` exits 0

...
```

### Phase 2: Complete the Task

After reading the task, you implement it according to the requirements. The script **waits** for you to confirm completion:

```
Have you completed task M001-S01-T02?
Before confirming, ensure:
  ✓ All must-haves implemented
  ✓ Artifact file(s) created/modified
  ✓ Truth test passes
  ✓ Code follows Go conventions (tabs, error handling, clarity)

Confirm completion (y/n): 
```

### Phase 3: Automated Quality Gates

Once you confirm, the script runs **Gate 3** (automated verification):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Running Gate 3 Quality Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Gate 3: Automated Checks (go test, go vet, golangci-lint, go build)
✓ go test passed
✓ Coverage: 87% (meets 80% threshold)
✓ go vet passed
✓ golangci-lint passed
✓ go build succeeded
✓ Gate 3 PASSED
```

**What Gate 3 checks:**
- `go test ./...` — All tests pass
- Coverage ≥ 80% (statements)
- `go vet ./...` — No suspicious constructs
- `golangci-lint run ./...` — Code style + linting
- `go build ./cmd/kind-cluster` — Binary compiles

If any check fails, the script stops and tells you what to fix:
```
✗ Coverage 45% below 80% threshold
✗ Quality gates failed. Fix issues and retry.
```

### Phase 4: Track Progress & Suggest Next Task

Once Gate 3 passes, the script:
- ✅ Marks the task complete
- 🔜 Finds the next incomplete task
- 📋 Displays requirements for the next task

```
✓ Task M001-S01-T02 marked complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Next Task: M001-S01-T03
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### M001-S01-T03: CI/CD Configuration
...
```

---

## Usage Patterns

### Pattern 1: Guided Sequential Execution

```bash
# Start GSD routine
bash gsd-manual

# Implement task in VS Code
# (script waits for your confirmation)

# Confirm completion when ready (type 'y')
# → Script runs quality gates
# → Shows next task automatically

# Repeat until all tasks complete
```

### Pattern 2: Interactive Sourcing

For more control, source the script and call functions manually:

```bash
source .gsd/manual-routine.sh

# Get current task
task=$(get_current_task)
echo "Current: $task"

# Show details
show_task_details "$task"

# Implement task...

# Run quality gates manually
run_quality_gates 3

# Then run full routine
gsd_next_task
```

### Pattern 3: Cron / Scheduled Reminders (Optional)

Create a cron job to remind you about the current task:

```bash
# In crontab -e
0 9 * * * cd /home/lfarizav/hdd-gsd2-hybrid-framework && bash .gsd/manual-routine.sh 2>&1 | head -20 | mail -s "Heritage GSD Task Reminder" user@example.com
```

---

## Mapping to ROADMAP.md

The script reads tasks from `.planning/ROADMAP.md` in this format:

```markdown
### M001-S01-T02: Go Module Setup

**Status:** Not Started
**Action:** Initialize Go module
**Must-Haves:**
1. go.mod created
2. Directory structure
3. Dependencies pinned
4. Example test created
5. Verification: go test && go build

**Artifact:** go.mod, go.sum, tests/unit/example_test.go
**Truth Test:** Output of go test ./... and go build ./cmd/kind-cluster
**Verify Command:** go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out && go build ./cmd/kind-cluster
```

**Key fields:**
- `### M<milestone>-S<slice>-T<task>` — Task ID (used to track progress)
- `**Status:**` — "Not Started" | "In Progress" | "Complete"
- `**Action:**` — What to implement (brief)
- `**Must-Haves:**` — Numbered requirements (essential deliverables)
- `**Artifact:**` — File(s) created/modified
- `**Truth Test:**` — Command output to verify
- `**Verify Command:**` — Exact shell command to validate

---

## Error Handling

### Test Failure
```
✗ go test failed
✗ Quality gates failed. Fix issues and retry.
```

**Fix:** Look at test output, fix the code, run `bash gsd-manual` again.

### Coverage Below Threshold
```
✗ Coverage 45% below 80% threshold
✗ Quality gates failed. Fix issues and retry.
```

**Fix:** Add more test cases. Use `go tool cover -html=coverage.out` to visualize uncovered code.

### Lint Warnings
```
⚠ golangci-lint warnings detected (check manually)
```

**Note:** Warnings don't fail the gate (they're informational). Fix if possible, but gate still passes.

### Build Failure
```
✗ go build failed
```

**Fix:** Fix compilation errors, then retry.

---

## Quality Gate Details

### Gate 1 — Specification Review (Human)
**When:** After Spec-Kit phase  
**Who:** Human reviewer  
**Checks:** Requirements clear? No ambiguities? Acceptance criteria objective?

### Gate 2 — Plan Review (Human)
**When:** After GSD-v1 planning phase  
**Who:** Human reviewer  
**Checks:** Plan complete? Research backing? Tasks achievable? Risks identified?

### Gate 3 — Automated Verification (Continuous)
**When:** After each task in M001  
**Who:** `bash gsd-manual` (automated)  
**Checks:**
- `go test ./...` ≥ 1 test passing
- Coverage ≥ 80%
- `go vet ./...` clean
- `golangci-lint` acceptable
- `go build ./cmd/kind-cluster` succeeds

### Gate 4 — Milestone Acceptance (Human)
**When:** After M001 complete (all 14 tasks done)  
**Who:** Human + project stakeholder  
**Checks:** All Gherkin scenarios pass? Documentation complete? Ready for production?

---

## Example: M001-S01-T02 Walkthrough

### Step 1: Run Automation

```bash
cd /home/lfarizav/hdd-gsd2-hybrid-framework
bash gsd-manual
```

### Step 2: Read Task Details

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Task Details: M001-S01-T02
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### M001-S01-T02: Go Module Setup

**Action:** Initialize Go module `github.com/lfarizav/heritage`

**Must-Haves:**
1. go.mod created with module name
2. Directories: cmd/kind-cluster, internal/kindcluster, internal/imageload, tests/
3. testify@latest pinned in go.mod
4. Example test: tests/unit/example_test.go with subtests
5. Verification: go test ./... && go build ./cmd/kind-cluster exit 0

**Artifact:** go.mod, go.sum, tests/unit/example_test.go

**Truth Test:** Output shows all tests pass, coverage > 80%
```

### Step 3: Implement

```bash
# Initialize module
go mod init github.com/lfarizav/heritage

# Create directories
mkdir -p cmd/kind-cluster internal/kindcluster internal/imageload tests/unit

# Add testify dependency
go get github.com/stretchr/testify@latest

# Create example test
cat > tests/unit/example_test.go <<'EOF'
package unit_test

import (
    "testing"
    "github.com/stretchr/testify/assert"
)

func TestExample(t *testing.T) {
    t.Run("example passes", func(t *testing.T) {
        assert.Equal(t, 1+1, 2)
    })
}
EOF

# Create minimal main
mkdir -p cmd/kind-cluster
cat > cmd/kind-cluster/main.go <<'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Heritage Kind Cluster Provisioner")
}
EOF
```

### Step 4: Confirm & Run Gates

```bash
# Script prompts:
Have you completed task M001-S01-T02?
Before confirming, ensure:
  ✓ All must-haves implemented
  ✓ Artifact file(s) created/modified
  ✓ Truth test passes
  ✓ Code follows Go conventions (tabs, error handling, clarity)

Confirm completion (y/n): y
```

### Step 5: Automated Verification

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Running Gate 3 Quality Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ℹ Gate 3: Automated Checks (go test, go vet, golangci-lint, go build)
✓ go test passed
✓ Coverage: 100% (meets 80% threshold)
✓ go vet passed
✓ golangci-lint passed
✓ go build succeeded
✓ Gate 3 PASSED

✓ Task M001-S01-T02 marked complete!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Next Task: M001-S01-T03
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

### M001-S01-T03: CI/CD Configuration
...
```

---

## Files

| File | Purpose |
|------|---------|
| `.gsd/manual-routine.sh` | Core automation logic (functions, gates, tracking) |
| `gsd-manual` | Wrapper script (easy entry point) |
| `.planning/ROADMAP.md` | Task definitions (read by automation) |
| `.planning/DECISIONS.md` | Append-only decision log (updated manually) |
| `.planning/KNOWLEDGE.md` | Shared facts for agents (updated manually) |

---

## Troubleshooting

### "ROADMAP.md not found"
```
✗ Not in heritage project root
```

**Solution:** Run from `/home/lfarizav/hdd-gsd2-hybrid-framework`:
```bash
cd /home/lfarizav/hdd-gsd2-hybrid-framework
bash gsd-manual
```

### "Go not found"
```
✗ Go not found. Install Go 1.22+ first.
```

**Solution:** Install Go:
```bash
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
```

### "No incomplete tasks found"
```
⚠ No incomplete tasks found. All tasks may be complete!
```

**Status:** M001 may be complete! Run Gate 4 milestone review:
```bash
# Manual Gate 4 (human acceptance)
# Check: All Gherkin scenarios pass?
# Check: Documentation complete?
# Decision: Ready for production?
```

---

## Next Steps

After each task completes:
1. Review the next task requirements
2. Implement in VS Code / terminal
3. Run `bash gsd-manual` to validate
4. Repeat until M001 complete (14 tasks)
5. Run Gate 4 milestone review

**Current Progress:**
- ✅ M001-S01-T01: Research Architecture (complete)
- ⏳ M001-S01-T02: Go Module Setup (next)
- ⏳ M001-S01-T03: CI/CD Configuration
- ⏳ M001-S02-S04: Implementation (12 tasks)

---

**Version:** 1.0  
**Last Updated:** May 2, 2026
