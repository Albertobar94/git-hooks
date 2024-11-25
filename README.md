# Git Package Manager Hooks

Automatic package manager detection and dependency installation using git hooks. This tool automatically detects your package manager (npm, yarn, or pnpm) and installs dependencies when switching branches if package.json has changed.

## Installation Options

### 1. Quick Installation (using curl)
```bash
curl -sSL https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash
```

### 2. Manual Installation
```bash
# Clone the repository
git clone https://github.com/albertobar94/git-hooks.git

# Install hooks
./install-hooks.sh
```

## Installation Methods

This tool supports two installation approaches:

1. **Standard Installation**
   - Installs in git's hooks directory
   - Affects the current repository
   - Automatically detects and integrates with husky if present

2. **Husky Integration**
   - Automatically detected if husky is installed
   - Uses husky's hook management
   - Ideal for projects already using husky

## Features

- 🔍 Automatically detects package manager (npm, yarn, or pnpm)
- 📦 Installs dependencies when switching branches if package.json changed
- 🛠️ Multiple installation methods (local, global, or husky)
- ⚡ Quick installation with curl
- 🔒 Safe and secure execution
- 🔄 Visual progress spinner with health monitoring
- ⏱️ Automatic timeout after 60 seconds
- 🛡️ Process health checks (zombie detection, CPU monitoring)

## How It Works

When you switch branches, the hook:
1. Detects if package.json has changed
2. Identifies your package manager by looking for lock files
3. Automatically runs the appropriate install command with progress indicator
4. Monitors installation health and terminates if:
   - Process becomes unresponsive (0% CPU for 5+ seconds)
   - Installation exceeds 60-second timeout
   - Process enters zombie state

## Hook Behavior

The hook triggers when:
- ✅ Switching branches
- ✅ package.json has changes between branches
- ✅ A package manager (npm, yarn, pnpm) is detected

It won't run when:
- ❌ Checking out individual files
- ❌ No package.json changes detected
- ❌ No package manager detected

## Troubleshooting

1. Check installation method:
```bash
git config core.hooksPath  # Should show .git/hooks for local installation
```

2. Verify hook permissions:
```bash
ls -l .git/hooks/post-checkout  # Should show executable permissions (chmod +x)
chmod +x .git/hooks/post-checkout  # Fix permissions if needed
```

3. Debug hook execution:
```bash
# Enable debug mode for more verbose output
export GIT_HOOKS_DEBUG=1
git checkout <branch-name>
```

4. Check hook script existence:
```bash
# Verify the hook file exists
ls -la .git/hooks/post-checkout

# View hook contents
cat .git/hooks/post-checkout
```

5. Common Issues:

- **Hook not executing:**
  - Ensure the hook file has executable permissions
  - Verify the hook path is correct
  - Check if Husky is conflicting (if installed)

- **Package manager not detected:**
  - Verify lock file exists (package-lock.json, yarn.lock, or pnpm-lock.yaml)
  - Ensure package manager is installed globally

- **Installation fails:**
  - Check write permissions in .git directory
  - Ensure curl/wget has internet access
  - Try manual installation method

6. Force reinstall latest version:
```bash
curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/albertobar94/git-hooks/main/uninstall-hooks.sh | bash && curl -H 'Cache-Control: no-cache' -o- https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash
```

## Security

The hook only runs package manager commands and does not execute any arbitrary code. It's safe to use in any Node.js project.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Uninstallation

To remove the hooks:

```bash
# Using curl
curl -sSL https://raw.githubusercontent.com/albertobar94/git-hooks/main/uninstall-hooks.sh | bash

# Or if you have the repository cloned
./uninstall-hooks.sh
```

The uninstaller will:
- Remove git hooks from the repository
- Clean up any related configurations
- Remove hooks directory if it exists