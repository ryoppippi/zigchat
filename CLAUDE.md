# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

zigchat is a CLI tool written in Zig that provides a simple interface to OpenAI's chat completions API. It uses the GPT-3.5-turbo model and requires an `OPENAI_API_KEY` environment variable.

## Development Commands

### Build
```bash
zig build                    # Build the project
zig build --release=fast     # Build optimized version
devbox run build            # Alternative using devbox
```

### Run
```bash
zig build run -- "your prompt here"    # Run with a prompt
devbox run run "your prompt here"      # Alternative using devbox
```

### Test
```bash
zig build test              # Run all tests
devbox run test            # Alternative using devbox
```

### Format
```bash
zig fmt .                   # Format code
devbox run fmt             # Alternative using devbox
zig build fmt-check        # Check formatting without modifying
```

## Architecture

The application is structured as a simple single-file CLI tool:

- **src/main.zig**: Contains all application logic including:
  - CLI argument parsing using the clap library
  - HTTP client setup for OpenAI API communication
  - JSON request/response handling
  - Error handling for API failures and missing environment variables

- **build.zig**: Zig build configuration that:
  - Defines the executable target
  - Configures cross-compilation for multiple platforms
  - Sets up test runner
  - Includes custom fmt-check step for CI

## Key Dependencies

- **clap v0.10.0**: Used for command-line argument parsing
- **Zig 0.14.0**: The project requires this specific version

## CI/CD Pipeline

The project uses GitHub Actions for:
- Format checking (zig fmt)
- Running tests
- Building binaries for Linux (x86_64, aarch64), Windows (x86_64), and macOS (x86_64, aarch64)
- Automated releases when tags are pushed

## Version Information

Note: There's a version mismatch between build.zig (0.6.0) and build.zig.zon (0.0.4) that should be reconciled.