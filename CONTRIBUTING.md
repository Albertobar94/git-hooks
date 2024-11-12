# Contributing

## Development Setup

1. Fork the repository
2. Clone your fork:
```bash
git clone https://github.com/albertobar94/git-hooks.git
```

3. Install dependencies:
```bash
pnpm install
```

This will automatically set up git hooks.

## Git Hooks

This project uses custom git hooks to maintain consistency:

- **post-checkout**: Automatically installs dependencies when switching branches if package.json has changed
- The hook detects your package manager (npm/yarn/pnpm) automatically

### Troubleshooting Hooks

If hooks aren't working:

1. Check if they're installed:
```bash
ls -la .hooks/
```

2. Reinstall if needed:
```bash
pnpm run setup
```

## Pull Request Process

1. Create a feature branch
2. Make your changes
3. Submit a pull request

Please ensure your PR:
- Follows the existing code style
- Includes appropriate tests
- Updates documentation as needed