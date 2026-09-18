# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

zigchat is a CLI tool written in Zig that provides a simple interface to OpenAI's chat completions API. It uses the GPT-3.5-turbo model and requires an `OPENAI_API_KEY` environment variable.

## Development Commands

### Build
```bash
zig build                    # Build the project
zig build --release=fast     # Build optimized version
nix build                   # Build using Nix
```

### Run
```bash
zig build run -- "your prompt here"    # Run with a prompt
nix run . -- "your prompt here"        # Run using Nix
```

### Test
```bash
zig build test              # Run all tests
```

### Format
```bash
zig fmt .                   # Format code
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

- **clap v0.11.0**: Used for command-line argument parsing
- **Zig 0.15.x**: The project requires Zig 0.15.x (currently using 0.15.2 via nixpkgs)
- **zon2nix**: Used to generate Nix expressions from build.zig.zon dependencies

## CI/CD Pipeline

The project uses GitHub Actions for:
- Format checking (zig fmt)
- Running tests
- Building binaries for Linux (x86_64, aarch64), Windows (x86_64), and macOS (x86_64, aarch64)
- Automated releases when tags are pushed

## Nix Integration

The project uses zon2nix for dependency management in Nix builds:
- **deps.nix**: Auto-generated from build.zig.zon using `zon2nix > deps.nix`
- **flake.nix**: Uses `zig_0_15.hook` from nixpkgs for build integration

To regenerate deps.nix after updating dependencies:
```bash
nix run nixpkgs#zon2nix > deps.nix
```