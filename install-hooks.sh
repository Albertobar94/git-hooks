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

# Function to create post-checkout hook content
create_post_checkout_content() {
    # Determine target directory based on arguments
    local target_dir="$1"
    
cat > "$target_dir/post-checkout" << 'EOF'
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
EOF
}

# Function to create utility script content
create_utility_script() {
mkdir -p scripts
cat > scripts/other-scripts.sh << 'EOF'
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
EOF
chmod +x scripts/other-scripts.sh
}

# Function to update package.json scripts
update_package_json() {
    if [ -f "package.json" ]; then
        # Check if jq is installed
        if ! command -v jq &> /dev/null; then
            print_status "⚠️  jq is not installed. Manual package.json update required."
            echo "Add these scripts to your package.json:"
            echo '"scripts": {'
            echo '  "postinstall": "bash scripts/install-hooks.sh",'
            echo '  "setup": "bash scripts/install-hooks.sh",'
            echo '  "hooks:verify": "bash scripts/other-scripts.sh verify",'
            echo '  "hooks:reset": "bash scripts/other-scripts.sh reset"'
            echo '}'
            return
        fi

        # Backup original package.json
        cp package.json package.json.backup

        # Update package.json with new scripts
        jq '.scripts += {
            "postinstall": "bash scripts/install-hooks.sh",
            "setup": "bash scripts/install-hooks.sh",
            "hooks:verify": "bash scripts/other-scripts.sh verify",
            "hooks:reset": "bash scripts/other-scripts.sh reset"
        }' package.json.backup > package.json

        print_success "✅ Updated package.json scripts"
    else
        print_status "⚠️  No package.json found. Skipping script updates."
    fi
}

# Function to update .gitignore
update_gitignore() {
    if [ ! -f ".gitignore" ]; then
        touch .gitignore
    fi
    
    if ! grep -q "^# Git hooks$" .gitignore; then
        echo -e "\n# Git hooks\n.hooks" >> .gitignore
        print_success "✅ Updated .gitignore to exclude .hooks directory"
    fi
}

# Main installation function
main() {
    # Accept installation method as command line argument
    local installation_method=${1:-"local"}  # Default to "local" if no argument provided

    # Check if husky is installed
    if [ -d "node_modules/husky" ]; then
        print_status "🐶 Husky detected, installing in husky hooks..."
        mkdir -p ".husky"
        create_post_checkout_content ".husky"
        chmod +x .husky/post-checkout
    else
        case $installation_method in
            "local")
                print_status "📂 Creating local hooks directory..."
                mkdir -p .hooks
                create_post_checkout_content ".hooks"
                chmod +x .hooks/post-checkout
                git config core.hooksPath .hooks
                update_gitignore
                ;;
            "global")
                print_status "📂 Installing in git hooks directory..."
                git_hooks_path=$(git rev-parse --git-path hooks)
                if [ ! -w "$git_hooks_path" ]; then
                    print_status "⚠️  Insufficient permissions for global hooks directory"
                    print_status "Try running with sudo: sudo bash install-hooks.sh global"
                    exit 1
                fi
                create_post_checkout_content "$git_hooks_path"
                chmod +x "$git_hooks_path/post-checkout"
                ;;
            *)
                echo "Usage: $0 [local|global]"
                echo "  local: Install in local .hooks directory (default)"
                echo "  global: Install in git hooks directory"
                exit 1
                ;;
        esac
    fi

    print_status "📝 Updating package.json..."
    update_package_json

    print_success "✅ Git hooks installed successfully!"
    print_status "
    Available commands:
    - npm run hooks:verify  : Verify hooks installation
    - npm run hooks:reset   : Reset and reinstall hooks
    "
}

# Run the installation with first command line argument
main "$1"