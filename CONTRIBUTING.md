# Contributing to programets

Thank you for your interest in contributing to **programets**! This document provides guidelines and information about how you can contribute.

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## How to Contribute

### Reporting Issues

Found a bug or have a feature request? Please open an issue at [GitHub Issues](https://github.com/nih-cfde/programets/issues).

When reporting a bug, please include:

- A clear description of the problem
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your R version and operating system
- Output from `sessionInfo()`

### Proposing Changes

We welcome pull requests! Here's how to get started:

1. **Fork the repository** and clone it locally
2. **Create a branch** for your changes: `git checkout -b feature/your-feature-name`
3. **Make your changes** following the code style guidelines below
4. **Test your changes** by running `devtools::check()`
5. **Commit your changes** with a clear commit message
6. **Push your branch** and open a pull request

### Development Setup

For detailed development setup instructions, including Google Analytics authentication and encryption configuration, see [DEVELOPER.md](DEVELOPER.md).

Basic setup:

```r
# Install development dependencies
devtools::install_deps(dependencies = TRUE)

# Run tests
devtools::test()

# Run R CMD check
devtools::check()
```

## Code Style

This project uses [lintr](https://lintr.r-lib.org/) for code style enforcement:

- Use 2-space indentation
- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Document functions using roxygen2 comments

Run the linter before submitting:

```r
lintr::lint_package()
```

## Questions?

If you have questions, feel free to open an issue or reach out to the maintainers listed in the [README](README.md).
