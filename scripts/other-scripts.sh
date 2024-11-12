#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to verify hooks installation
verify_hooks() {
    if [ -f ".hooks/post-checkout" ]; then
        echo -e "${GREEN}✓ post-checkout hook is installed${NC}"
        if [ -x ".hooks/post-checkout" ]; then
            echo -e "${GREEN}✓ post-checkout hook is executable${NC}"
        else
            echo -e "${RED}✗ post-checkout hook is not executable${NC}"
            echo "Run: chmod +x .hooks/post-checkout"
        fi
    else
        echo -e "${RED}✗ post-checkout hook is not installed${NC}"
        echo "Run: npm run setup"
    fi
}

# Function to clean and reinstall hooks
reset_hooks() {
    echo -e "${BLUE}Cleaning hooks...${NC}"
    rm -rf .hooks
    bash scripts/install-hooks.sh
}

# Parse command line arguments
case "$1" in
    "verify")
        verify_hooks
        ;;
    "reset")
        reset_hooks
        ;;
    *)
        echo "Usage: $0 {verify|reset}"
        echo "  verify: Check if hooks are properly installed"
        echo "  reset: Remove and reinstall hooks"
        exit 1
        ;;
esac
