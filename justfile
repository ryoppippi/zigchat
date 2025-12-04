# Build the project
build *ARGS:
    zig build {{ARGS}}

# Build release version
build-release *ARGS:
    zig build --release=safe {{ARGS}}

# Run tests
test:
    zig build test

# Format code
fmt:
    zig fmt src/*.zig build.zig build.zig.zon

# Check formatting
fmt-check:
    zig fmt --check src/*.zig build.zig build.zig.zon

# Generate deps.nix from build.zig.zon
zon2nix:
    zon2nix > deps.nix

# Run the application
run *ARGS:
    zig build run -- {{ARGS}}
