#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${BLUE}$1${NC}"
}

# Function to print success
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Main uninstallation function
main() {
    # Remove local hooks
    print_status "🗑️  Removing local git hooks..."

    # Reset git hooks path to default
    git config --unset core.hooksPath

    # Remove .hooks directory if it exists
    if [ -d ".hooks" ]; then
        rm -rf .hooks
        print_status "✅ Removed .hooks directory"
    fi

    # Remove the .hooks entry from .gitignore
    if [ -f ".gitignore" ]; then
        # Create a temporary file without the git hooks section
        sed '/^# Git hooks$/d' .gitignore | sed '/^\.hooks$/d' > .gitignore.tmp
        mv .gitignore.tmp .gitignore
        print_status "✅ Updated .gitignore"
    fi

    # Remove global hooks
    print_status "🗑️  Removing global git hooks..."
    git_hooks_path=$(git rev-parse --git-path hooks)
    
    if [ -f "$git_hooks_path/post-checkout" ]; then
        if [ -w "$git_hooks_path/post-checkout" ]; then
            rm "$git_hooks_path/post-checkout"
            print_status "✅ Removed global post-checkout hook"
        else
            print_status "⚠️  Insufficient permissions to remove global hook"
            print_status "Try running with sudo: sudo bash uninstall-hooks.sh"
        fi
    fi

    print_success "✅ Git hooks uninstallation complete!"
}

# Run the uninstallation
main 