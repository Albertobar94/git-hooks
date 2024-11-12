# Git Package Manager Hooks

Automatic package manager detection and dependency installation using git hooks. This tool automatically detects your package manager (npm, yarn, or pnpm) and installs dependencies when switching branches if package.json has changed.

## Installation Options

### 1. Quick Installation (using curl)
```bash
# Default local installation
curl -sSL https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash

# Or specify installation method
curl -sSL https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash -s -- global
```

### 2. With Husky
```bash
# Install husky as dev dependency
npm install --save-dev husky

# Install hooks
npm run setup
```

### 3. Manual Installation
```bash
# Clone the repository
git clone https://github.com/albertobar94/git-hooks.git

# Install with specific method
./install-hooks.sh local  # or global
```

## Installation Methods

This tool supports multiple installation approaches:

1. **Local Installation** (Recommended)
   - Creates a `.hooks` directory in your project
   - Automatically added to .gitignore
   - Keeps hooks specific to each project

2. **Global Installation**
   - Installs in git's global hooks directory
   - Affects all repositories on your machine
   - Useful for maintaining consistent hooks across projects

3. **Husky Integration**
   - Automatically detected if husky is installed
   - Uses husky's hook management
   - Ideal for projects already using husky

## Features

- 🔍 Automatically detects package manager (npm, yarn, or pnpm)
- 📦 Installs dependencies when switching branches if package.json changed
- 🛠️ Multiple installation methods (local, global, or husky)
- ⚡ Quick installation with curl
- 🔒 Safe and secure execution

## How It Works

When you switch branches, the hook:
1. Detects if package.json has changed
2. Identifies your package manager by looking for lock files
3. Automatically runs the appropriate install command

## Available Scripts

```bash
# Verify hooks installation
npm run hooks:verify

# Reset and reinstall hooks
npm run hooks:reset

# Manual installation/setup
npm run setup
```

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

If the hooks aren't working:

1. Verify installation:
```bash
npm run hooks:verify
```

2. Reset hooks:
```bash
npm run hooks:reset
```

3. Check installation method:
```bash
git config core.hooksPath  # Should show .hooks for local installation
```

## Security

The hook only runs package manager commands and does not execute any arbitrary code. It's safe to use in any Node.js project.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.