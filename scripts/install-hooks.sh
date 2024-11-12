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

# Main installation function
install_hooks() {
    print_status "📂 Creating hooks directory..."
    mkdir -p .hooks

    print_status "📥 Installing post-checkout hook..."
    cp scripts/hooks/post-checkout .hooks/post-checkout
    chmod +x .hooks/post-checkout

    print_status "⚙️  Configuring git to use hooks..."
    git config core.hooksPath .hooks

    print_success "✅ Git hooks installed successfully!"
}

# Run the installation
install_hooks