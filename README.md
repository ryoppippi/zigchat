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
This project uses [Nix flakes](https://nixos.wiki/wiki/Flakes) to manage the development environment.

### Setup
```bash
# Enter the development shell
nix develop

# Or use direnv for automatic environment loading
echo "use flake" > .envrc
direnv allow
```

### Build
```bash
# Build the project
nix build

# Or within the dev shell
zig build
```

※  If you want to compile in `0.11.0` see the `zig-0.11.0` branch.


## Authors

- Ryotaro "Justin" Kimura http://github.com/ryoppippi

## License
MIT


