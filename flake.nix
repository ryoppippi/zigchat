{
  description = "zigchat - CLI tool for OpenAI chat completions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        zigchat = pkgs.stdenv.mkDerivation {
          pname = "zigchat";
          version = "0.6.0";
          
          src = ./.;
          
          nativeBuildInputs = with pkgs; [
            zig
          ];
          
          buildPhase = ''
            zig build --release=fast
          '';
          
          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/zigchat $out/bin/
          '';
        };
      in
      {
        packages = {
          default = zigchat;
          zigchat = zigchat;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            zig
            zls
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