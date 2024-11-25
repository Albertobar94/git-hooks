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

# Function to create shared hook content
create_shared_hook_content() {
    cat << 'EOF'
#!/bin/bash

# Spinner function for visual feedback with timeout and health checks
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    local timeout=60  # 60 seconds timeout
    local start_time=$(date +%s)
    
    while true; do
        # Check if process exists
        if ! ps -p $pid > /dev/null; then
            printf "    \b\b\b\b"
            return 0
        fi
        
        # Check if process is zombie
        if ps -p $pid -o state= | grep -q "Z"; then
            echo "⚠️  Process became zombie, terminating..."
            kill -9 $pid 2>/dev/null
            return 1
        fi
        
        # Check CPU usage (get the CPU percentage, remove % sign and compare)
        local cpu_usage=$(ps -p $pid -o %cpu= | tr -d ' ')
        if [ "${cpu_usage%.*}" = "0" ]; then
            local zero_cpu_time=$(($(date +%s) - start_time))
            if [ $zero_cpu_time -gt 5 ]; then  # If CPU is 0% for more than 5 seconds
                echo "⚠️  Process appears frozen (0% CPU), terminating..."
                kill -9 $pid 2>/dev/null
                return 1
            fi
        fi
        
        # Check timeout
        local current_time=$(date +%s)
        local elapsed_time=$((current_time - start_time))
        if [ $elapsed_time -gt $timeout ]; then
            echo "⚠️  Process timed out after ${timeout} seconds, terminating..."
            kill -9 $pid 2>/dev/null
            return 1
        fi
        
        # Update spinner animation
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        printf "\b\b\b\b\b\b"
        sleep $delay
    done
}

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

# Function to check and install dependencies
check_and_install_dependencies() {
    local previous_head=$1
    local new_head=$2
    
    echo "🔍 Checking for package.json changes between $previous_head and $new_head..."
    
    # Check if package.json has changed between commits
    if git diff --name-only $previous_head $new_head | grep -q "^package.json$"; then
        echo "📦 package.json changes detected"
        
        # Detect package manager
        package_manager=$(detect_package_manager)
        
        echo "🗑️  Removing node_modules..."
        rm -rf node_modules
        
        case $package_manager in
            "pnpm")
                echo "🔍 pnpm detected, installing dependencies..."
                (pnpm install --frozen-lockfile > /dev/null 2>&1 || pnpm install) &
                spinner $! || { echo "❌ Installation failed"; exit 1; }
                ;;
            "yarn")
                echo "🔍 yarn detected, installing dependencies..."
                (yarn install --frozen-lockfile > /dev/null 2>&1 || yarn install) &
                spinner $! || { echo "❌ Installation failed"; exit 1; }
                ;;
            "npm")
                echo "🔍 npm detected, installing dependencies..."
                (npm ci > /dev/null 2>&1 || npm install) &
                spinner $! || { echo "❌ Installation failed"; exit 1; }
                ;;
            *)
                echo "⚠️  No package manager detected. Please run install manually if needed."
                ;;
        esac
        
        echo "✅ Dependency installation complete"
    else
        echo "ℹ️  No changes in package.json, skipping dependency installation"
    fi
}
EOF
}

# Function to create post-checkout hook content
create_post_checkout_content() {
    local target_dir="$1"
    
    # First, write the shared content
    create_shared_hook_content > "$target_dir/post-checkout"
    
    # Then append post-checkout specific content
    cat >> "$target_dir/post-checkout" << 'EOF'

# Get the previous and current commit hashes from git hook parameters
previous_head="$1"
new_head="$2"
checkout_type="$3"

# Only run on branch checkout, not file checkout
if [ "$checkout_type" = "1" ] && [ -n "$previous_head" ] && [ -n "$new_head" ]; then
    echo "🔄 Branch checkout detected, checking dependencies..."
    check_and_install_dependencies "$previous_head" "$new_head"
fi
EOF
}

# Function to create post-merge hook content
create_post_merge_content() {
    local target_dir="$1"
    
    # First, write the shared content
    create_shared_hook_content > "$target_dir/post-merge"
    
    # Then append post-merge specific content
    cat >> "$target_dir/post-merge" << 'EOF'

# In post-merge, ORIG_HEAD contains the pre-merge state
echo "🔄 Merge detected, checking dependencies..."
check_and_install_dependencies "ORIG_HEAD" "HEAD"
EOF
}

# Function to verify hook installation
verify_hook_installation() {
    local hook_path="$1"
    local hook_name="$2"
    
    if [ -f "$hook_path/$hook_name" ]; then
        if [ -x "$hook_path/$hook_name" ]; then
            print_success "✅ $hook_name hook is installed and executable"
            return 0
        else
            print_status "⚠️  $hook_name hook is installed but not executable"
            return 1
        fi
    else
        print_status "⚠️  $hook_name hook is not installed"
        return 1
    fi
}

# Function to get git hooks path
get_git_hooks_path() {
    if [ -n "$SUDO_USER" ]; then
        # If running with sudo, get the path as the regular user
        local git_dir=$(su - "$SUDO_USER" -c "cd \"$PWD\" && git rev-parse --git-dir")
        echo "$PWD/$git_dir/hooks"
    else
        local git_dir=$(git rev-parse --git-dir)
        echo "$PWD/$git_dir/hooks"
    fi
}

# Function to check if husky is properly installed and setup
check_husky_setup() {
    # Check if husky is in package.json dependencies or devDependencies
    if ! grep -q '"husky"' package.json 2>/dev/null; then
        return 1
    fi

    # Check if husky is installed in node_modules
    if [ ! -d "node_modules/husky" ]; then
        return 1
    fi

    # Check if husky is initialized (.husky directory exists and contains .gitignore)
    if [ ! -d ".husky" ] || [ ! -f ".husky/.gitignore" ]; then
        return 1
    fi

    # Check if husky is tracked by git
    if ! git ls-files --error-unmatch .husky/.gitignore >/dev/null 2>&1; then
        return 1
    fi

    return 0
}

# Main installation function
main() {
    print_status "📂 Installing in git hooks directory..."
    git_hooks_path=$(get_git_hooks_path)
    print_status "Installing hooks in: $git_hooks_path"
    local installation_success=true

    if check_husky_setup; then
        print_status "🐶 Husky detected and properly configured, installing in husky hooks..."
        create_post_checkout_content ".husky"
        create_post_merge_content ".husky"
        chmod +x .husky/post-checkout
        chmod +x .husky/post-merge
        
        # Verify husky hooks
        verify_hook_installation ".husky" "post-checkout" || installation_success=false
        verify_hook_installation ".husky" "post-merge" || installation_success=false
    else
        if [ ! -d "$git_hooks_path" ]; then
            print_status "Creating hooks directory..."
            mkdir -p "$git_hooks_path"
        fi
        
        if [ ! -w "$git_hooks_path" ] && [ -z "$SUDO_USER" ]; then
            print_status "⚠️  Insufficient permissions for git hooks directory"
            print_status "Try one of these options:"
            print_status "1. Run with sudo: sudo bash install-hooks.sh"
            print_status "2. Try direct installation: curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash"
            exit 1
        fi
        
        print_status "Creating post-checkout hook..."
        create_post_checkout_content "$git_hooks_path"
        
        print_status "Creating post-merge hook..."
        create_post_merge_content "$git_hooks_path"
        
        print_status "Setting permissions..."
        chmod +x "$git_hooks_path/post-checkout"
        chmod +x "$git_hooks_path/post-merge"
        
        # If running with sudo, fix ownership
        if [ -n "$SUDO_USER" ]; then
            print_status "Fixing ownership..."
            chown "$SUDO_USER:$(id -gn $SUDO_USER)" "$git_hooks_path/post-checkout"
            chown "$SUDO_USER:$(id -gn $SUDO_USER)" "$git_hooks_path/post-merge"
        fi
        
        # Verify hooks
        verify_hook_installation "$git_hooks_path" "post-checkout" || installation_success=false
        verify_hook_installation "$git_hooks_path" "post-merge" || installation_success=false
    fi

    if [ "$installation_success" = true ]; then
        print_success "✅ Git hooks installed successfully!"
    else
        print_status "⚠️  Some issues were detected during installation"
        print_status "💡 Try direct installation: curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash"
        exit 1
    fi
}

# Call main function with all arguments
main "$@"