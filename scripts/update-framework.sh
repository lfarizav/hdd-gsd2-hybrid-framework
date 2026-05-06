#!/bin/bash
# update-framework.sh — Auto-update HDD-GSD2 hybrid framework to latest version
# Usage: bash scripts/update-framework.sh [--force]
#
# Features:
#   - Fetches latest from origin
#   - Checks for uncommitted changes and stashes if needed
#   - Pulls latest main branch
#   - Reports success/failure with diff summary
#   - Use --force to skip confirmation prompts

set -e

FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BRANCH="${1:---main}"  # Default to main, allow override
FORCE="${2:---force}"

cd "$FRAMEWORK_ROOT"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║  HDD-GSD2 Hybrid Framework Auto-Update                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Check git status
echo "[1/5] Checking git status..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
CURRENT_COMMIT=$(git rev-parse --short HEAD)

if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "⚠️  Warning: Currently on branch '$CURRENT_BRANCH' (not main)"
    echo "    Switching to main..."
    git checkout main
fi

echo "      Current branch: main"
echo "      Current commit: $CURRENT_COMMIT"
echo ""

# Step 2: Check for uncommitted changes
echo "[2/5] Checking for uncommitted changes..."
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Uncommitted changes detected."
    
    if [ "$FORCE" == "--force" ]; then
        echo "    [--force] Stashing changes automatically..."
        STASH_ID=$(git stash push -m "auto-update-$(date +%s)" | grep -oP 'Saved working directory' && echo "stashed")
        echo "    Changes stashed (use 'git stash pop' to restore)"
    else
        echo ""
        read -p "    Stash changes before updating? (y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git stash push -m "auto-update-$(date +%s)"
            echo "    Changes stashed"
        else
            echo "❌ Aborting update. Commit or stash changes first."
            exit 1
        fi
    fi
fi
echo ""

# Step 3: Fetch latest
echo "[3/5] Fetching latest from origin..."
git fetch origin main
REMOTE_COMMIT=$(git rev-parse --short origin/main)
echo "      Remote commit: $REMOTE_COMMIT"
echo ""

# Step 4: Check if updates available
echo "[4/5] Checking for available updates..."
BEHIND=$(git rev-list --count main..origin/main)
AHEAD=$(git rev-list --count origin/main..main)

if [ "$BEHIND" -eq 0 ] && [ "$AHEAD" -eq 0 ]; then
    echo "✅ Already up to date!"
    echo ""
    git log --oneline -3
    exit 0
fi

if [ "$BEHIND" -gt 0 ]; then
    echo "🔄 New updates available ($BEHIND commits behind origin/main)"
    echo ""
    echo "   New commits:"
    git log --oneline main..origin/main | sed 's/^/   /'
    echo ""
fi

if [ "$AHEAD" -gt 0 ]; then
    echo "⚠️  Local commits ahead of origin ($AHEAD commits)"
    echo ""
    echo "   Local commits:"
    git log --oneline origin/main..main | sed 's/^/   /'
    echo ""
fi

# Step 5: Pull latest
echo "[5/5] Pulling latest changes..."
git pull origin main

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  ✅ Update complete!                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Recent commits:"
git log --oneline -5 | sed 's/^/  /'
echo ""

# Show what changed
echo "Files modified in last 3 commits:"
git diff --name-only HEAD~3..HEAD 2>/dev/null | sed 's/^/  /' || echo "  (none)"
