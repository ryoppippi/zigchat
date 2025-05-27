{
  description = "zigchat - CLI tool for OpenAI chat completions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        zigPkgs = zig-overlay.packages.${system};
        zig = zigPkgs."0.14.0";
        
        zigchat = pkgs.stdenv.mkDerivation {
          pname = "zigchat";
          version = "0.7.0";
          
          src = ./.;
          
          nativeBuildInputs = [
            zig
            pkgs.zig.hook
          ];
          
          zigBuildFlags = [ "--release=fast" ];
        };
      in
      {
        packages = {
          default = zigchat;
          zigchat = zigchat;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            zig
            pkgs.zls
          ];

          shellHook = ''
            echo "zigchat development environment"
            zig version
            
            # Define convenient shell functions
            build() {
              zig build --verbose "$@"
            }
            
            test() {
              zig build test
            }
            
            fmt() {
              zig fmt src/*.zig *.zig *.zon
            }
            
            fmt-check() {
              zig fmt --check src/*.zig *.zig *.zon
            }
            
            run() {
              ./zig-out/bin/zigchat "$@"
            }
            
            export -f build test fmt fmt-check run
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = zigchat;
        };
      });
}
