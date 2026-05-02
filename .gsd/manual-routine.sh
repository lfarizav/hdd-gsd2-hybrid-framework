#!/bin/bash
#
# GSD-2 Manual Execution Routine
# ==============================
#
# Automates the repetitive task of manual GSD-2 execution when CLI is unavailable.
# Usage:
#   source .gsd/manual-routine.sh && gsd_next_task
#   # or
#   bash .gsd/manual-routine.sh
#
# This script:
# 1. Reads current task from .planning/ROADMAP.md
# 2. Displays task requirements (must-haves, artifact, verification)
# 3. Guides you through execution
# 4. Runs quality gates automatically
# 5. Updates task status in tracking
# 6. Suggests next task

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
ROADMAP_PATH=".planning/ROADMAP.md"
DECISIONS_PATH=".planning/DECISIONS.md"
KNOWLEDGE_PATH=".planning/KNOWLEDGE.md"
TODO_PATH=".planning/TODO.md"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

log_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

log_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ${1}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ============================================================================
# Task Tracking
# ============================================================================

# Parse ROADMAP.md to find current task (first incomplete one)
get_current_task() {
    if [[ ! -f "$ROADMAP_PATH" ]]; then
        log_error "ROADMAP.md not found at $ROADMAP_PATH"
        return 1
    fi
    
    # Find first task with status "Not Started" (case-insensitive grep)
    grep -i "status.*not started\|status.*in-progress" "$ROADMAP_PATH" | head -1 | grep -oP 'M\d+-S\d+-T\d+' | head -1
}

# Parse task details from ROADMAP
get_task_details() {
    local task_id=$1
    
    if ! grep -q "$task_id" "$ROADMAP_PATH"; then
        log_error "Task $task_id not found in ROADMAP"
        return 1
    fi
    
    # Extract task section (between task ID and next task or end)
    local task_section=$(sed -n "/^### $task_id/,/^### M[0-9]/p" "$ROADMAP_PATH" | head -n -1)
    
    echo "$task_section"
}

# ============================================================================
# Quality Gates
# ============================================================================

run_quality_gates() {
    local gate_level=$1
    
    log_section "Running Gate $gate_level Quality Checks"
    
    case $gate_level in
        3)
            log_info "Gate 3: Automated Checks (go test, go vet, golangci-lint, go build)"
            
            # Test
            if ! go test -coverprofile=coverage.out ./... ; then
                log_error "go test failed"
                return 1
            fi
            log_success "go test passed"
            
            # Coverage
            coverage=$(go tool cover -func=coverage.out 2>/dev/null | tail -1 | awk '{print $3}' | sed 's/%//')
            if (( $(echo "$coverage < 80" | bc -l) )); then
                log_error "Coverage $coverage% below 80% threshold"
                return 1
            fi
            log_success "Coverage: $coverage% (meets 80% threshold)"
            
            # Vet
            if ! go vet ./... ; then
                log_error "go vet failed"
                return 1
            fi
            log_success "go vet passed"
            
            # Lint
            if ! golangci-lint run ./... ; then
                log_warning "golangci-lint warnings detected (check manually)"
            else
                log_success "golangci-lint passed"
            fi
            
            # Build
            if ! go build ./cmd/kind-cluster ; then
                log_error "go build failed"
                return 1
            fi
            log_success "go build succeeded"
            
            log_success "Gate 3 PASSED"
            ;;
        1)
            log_info "Gate 1: Specification Review (human review checkpoint)"
            log_warning "Please manually review specs for clarity and no ambiguities"
            ;;
        2)
            log_info "Gate 2: Plan Review (human review checkpoint)"
            log_warning "Please manually review plan for completeness and research backing"
            ;;
        4)
            log_info "Gate 4: Milestone Review (human acceptance checkpoint)"
            log_warning "Milestone complete. Please perform final acceptance review."
            ;;
    esac
}

# ============================================================================
# Task Execution Guidance
# ============================================================================

show_task_details() {
    local task_id=$1
    
    log_section "Task Details: $task_id"
    
    local details=$(get_task_details "$task_id")
    echo "$details"
    
    echo ""
    echo -e "${YELLOW}Key Sections to Complete:${NC}"
    echo "  • action (what to implement)"
    echo "  • must-haves (required deliverables)"
    echo "  • artifact (file to create/modify)"
    echo "  • truth test (how to verify)"
    echo "  • verify command (exact command to run)"
}

prompt_task_complete() {
    local task_id=$1
    
    echo ""
    echo -e "${YELLOW}Have you completed task $task_id?${NC}"
    echo "Before confirming, ensure:"
    echo "  ✓ All must-haves implemented"
    echo "  ✓ Artifact file(s) created/modified"
    echo "  ✓ Truth test passes"
    echo "  ✓ Code follows Go conventions (tabs, error handling, clarity)"
    echo ""
    read -p "Confirm completion (y/n): " -r
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ============================================================================
# Main Routine
# ============================================================================

gsd_next_task() {
    log_section "GSD-2 Manual Execution Routine"
    
    local current_task=$(get_current_task)
    
    if [[ -z "$current_task" ]]; then
        log_warning "No incomplete tasks found. All tasks may be complete!"
        echo "Upcoming tasks:"
        grep -E "^### M[0-9]+-S[0-9]+-T[0-9]+" "$ROADMAP_PATH" | head -5
        return 0
    fi
    
    log_info "Current task: $current_task"
    
    # Show task details
    show_task_details "$current_task"
    
    # Prompt for task completion
    if ! prompt_task_complete "$current_task"; then
        log_info "Task not yet complete. Come back when ready!"
        return 0
    fi
    
    # Run quality gates (Gate 3)
    if ! run_quality_gates 3; then
        log_error "Quality gates failed. Fix issues and retry."
        return 1
    fi
    
    # Update task status
    log_info "Marking $current_task as complete..."
    sed -i.bak "s/\[$current_task\] Not Started/\[$current_task\] Complete/" .planning/TODO.md 2>/dev/null || true
    
    log_success "Task $current_task marked complete!"
    
    # Suggest next task
    local next_task=$(get_current_task)
    if [[ -n "$next_task" ]]; then
        log_section "Next Task: $next_task"
        show_task_details "$next_task"
    fi
}

# ============================================================================
# Standalone Execution
# ============================================================================

main() {
    # Check if we're in the right directory
    if [[ ! -f "$ROADMAP_PATH" ]]; then
        log_error "Not in heritage project root. Run from: /home/lfarizav/hdd-gsd2-hybrid-framework"
        return 1
    fi
    
    # Check Go is installed
    if ! command -v go &> /dev/null; then
        log_error "Go not found. Install Go 1.22+ first."
        return 1
    fi
    
    # Run the routine
    gsd_next_task
}

# Export function for sourcing
export -f log_info log_success log_error log_warning log_section
export -f get_current_task get_task_details run_quality_gates
export -f show_task_details prompt_task_complete gsd_next_task

# Run if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
