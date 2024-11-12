#!/bin/bash

# Function to create hook content
create_hook_content() {
cat << 'EOL'
#!/bin/bash

# Get the previous and current commit hashes from git hook parameters
previous_head=$1
new_head=$2
checkout_type=$3

# Function to detect package manager based on lock files
detect_package_manager() {
    if [ -f "pnpm-lock.yaml" ]; then
        echo "pnpm"
    elif [ -f "yarn.lock" ]; then
        echo "yarn"
    elif [ -f "package-lock.json" ]; then
        echo "npm"
    else
        echo "unknown"
    fi
}

# Only run on branch checkout, not file checkout
if [ $checkout_type -eq 1 ]; then
    # Check if package.json has changed between commits
    if git diff --name-only $previous_head $new_head | grep -q "^package.json$"; then
        echo "📦 package.json changes detected"
        
        # Detect package manager
        package_manager=$(detect_package_manager)
        
        case $package_manager in
            "pnpm")
                echo "🔍 pnpm detected, installing dependencies..."
                pnpm install
                ;;
            "yarn")
                echo "🔍 yarn detected, installing dependencies..."
                yarn install
                ;;
            "npm")
                echo "🔍 npm detected, installing dependencies..."
                npm install
                ;;
            *)
                echo "⚠️  No package manager detected. Please run install manually if needed."
                ;;
        esac
        
        echo "✅ Dependency installation complete"
    else
        echo "ℹ️  No changes in package.json, skipping dependency installation"
    fi
fi
EOL
}

# Main installation logic
main() {
    echo "📥 Installing package manager git hook..."
    
    # Create .hooks directory if it doesn't exist
    mkdir -p .hooks
    
    # Create the hook file
    create_hook_content > .hooks/post-checkout
    
    # Make it executable
    chmod +x .hooks/post-checkout
    
    # Set git config to use the .hooks directory
    git config core.hooksPath .hooks
    
    echo "✅ Git hook installed successfully!"
    echo "🔍 The hook will run automatically when switching branches"
}

# Run the installation
main