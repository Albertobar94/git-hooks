# Contributing

## Development Setup

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/albertobar94/git-hooks.git
```

3. Install the hooks:
```bash
./install-hooks.sh
```

## Git Hooks

This project uses custom git hooks to maintain consistency:

- **post-checkout**: Automatically installs dependencies when switching branches if package.json has changed
- **post-merge**: Automatically installs dependencies after merges if package.json has changed
- The hooks detect your package manager (npm/yarn/pnpm) automatically

### Troubleshooting Hooks

If hooks aren't working:

1. Verify the installation:
```bash
git config core.hooksPath  # Should show the git hooks path
ls -la $(git rev-parse --git-path hooks)  # Should show the hooks
```

2. Reinstall if needed:
```bash
./install-hooks.sh
```

3. If issues persist, try uninstalling and reinstalling:
```bash
./uninstall-hooks.sh
./install-hooks.sh
```

## Pull Request Process

1. Create a feature branch
2. Make your changes
3. Submit a pull request

Please ensure your PR:
- Follows the existing code style
- Includes appropriate tests
- Updates documentation as needed