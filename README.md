# Git Package Manager Hooks

Automatic package manager detection and dependency installation using git hooks. This tool automatically detects your package manager (npm, yarn, or pnpm) and installs dependencies when switching branches if package.json has changed.

## Quick Start

### Option 1: Quick Installation (using curl)
```bash
curl -sSL https://raw.githubusercontent.com/albertobar94/git-hooks/main/install-hooks.sh | bash
```

### Option 2: Manual Installation
```bash
# Clone the repository
git clone https://github.com/albertobar94/git-hooks.git

# Install dependencies (this will also install the hooks)
npm install
# or
yarn install
# or
pnpm install
```

## Features

- 🔍 Automatically detects package manager (npm, yarn, or pnpm)
- 📦 Installs dependencies when switching branches if package.json changed
- ⚡ Quick installation with curl
- 🛠️ Works with any Node.js project

## How It Works

When you switch branches, the hook:
1. Detects if package.json has changed
2. Identifies your package manager by looking for lock files
3. Automatically runs the appropriate install command

## Available Scripts

```bash
# Manually install hooks
npm run setup

# Verify hooks installation
npm run hooks:verify

# Reset and reinstall hooks
npm run hooks:reset
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

3. Manual installation:
```bash
bash scripts/install-hooks.sh
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Security

The hook only runs package manager commands and does not execute any arbitrary code. It's safe to use in any Node.js project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.