# zigchat ZIG ❤️ OPENAI

![GitHub Release](https://img.shields.io/github/v/release/ryoppippi/zigchat)
[![Zig](https://custom-icon-badges.herokuapp.com/badge/Zig-ec915c.svg?logo=Zig&logoColor=white)]()
[![Built with Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3.svg?logo=nixos&logoColor=white)](https://nixos.org/)
[![.github/workflows/ci.yaml](https://github.com/ryoppippi/zigchat/actions/workflows/ci.yaml/badge.svg)](https://github.com/ryoppippi/zigchat/actions/workflows/ci.yaml)


![画面収録 2023-09-24 11 59 49](https://github.com/ryoppippi/zigchat/assets/1560508/f1f1533d-0cc7-44ec-ae3b-219ecd9992b7)

## Install

### GitHub Releases

Download a prebuilt binary from [GitHub Releases](https://github.com/ryoppippi/zigchat/releases) and install it in $PATH.

### aqua

[aqua](https://aquaproj.github.io/) is a CLI Version Manager.

```bash
aqua g -i ryoppippi/zigchat
```

## How to run

```bash
export OPENAI_API_KEY=<your key>
zigchat "Hello!"
```

## Development
This project uses [Nix flakes](https://nixos.wiki/wiki/Flakes) and [just](https://github.com/casey/just) for development.

### Quick Start
```bash
# Run directly from GitHub
nix shell github:ryoppippi/zigchat -c zigchat "Hello!"

# Or build locally
nix build
./result/bin/zigchat "Hello!"
```

### Development Environment
```bash
# Enter development shell
nix develop

# Use just commands
just build           # Build the project
just build-release   # Build with release optimisation
just test            # Run tests
just fmt             # Format code
just fmt-check       # Check formatting
just run "Hello!"    # Run the application
just zon2nix         # Regenerate deps.nix
```


## Authors

- Ryotaro "Justin" Kimura http://github.com/ryoppippi

## License
MIT


