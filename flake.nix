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
        
        # Pre-fetch zig-clap dependency
        zig-clap = pkgs.fetchFromGitHub {
          owner = "Hejsil";
          repo = "zig-clap";
          rev = "0.10.0";
          sha256 = "sha256-leXnA97ITdvmBhD2YESLBZAKjBg+G4R/+PPPRslz/ec=";
        };
        
        zigchat = pkgs.stdenv.mkDerivation {
          pname = "zigchat";
          version = "0.7.0";
          
          src = ./.;
          
          nativeBuildInputs = [
            zig
            pkgs.cacert
          ];
          
          buildPhase = ''
            export HOME=$TMPDIR
            export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
            
            # Setup Zig cache with pre-fetched dependencies
            export ZIG_CACHE_DIR=$TMPDIR/zig-cache
            export ZIG_LOCAL_CACHE_DIR=$TMPDIR/zig-local-cache
            mkdir -p $ZIG_CACHE_DIR/p
            
            # Copy pre-fetched zig-clap to the cache
            cp -r ${zig-clap} $ZIG_CACHE_DIR/p/clap-0.10.0-oBajB434AQBDh-Ei3YtoKIRxZacVPF1iSwp3IX_ZB8f0
            
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
