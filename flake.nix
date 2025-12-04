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
        zig = zigPkgs."0.15.2";

        zigchat = pkgs.stdenv.mkDerivation {
          pname = "zigchat";
          version = "0.7.0";

          src = ./.;

          nativeBuildInputs = [ zig ];

          configurePhase = ''
            runHook preConfigure
            export ZIG_GLOBAL_CACHE_DIR=$(mktemp -d)
            ln -s ${pkgs.callPackage ./deps.nix { }} $ZIG_GLOBAL_CACHE_DIR/p
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            zig build --release=safe
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/bin
            cp zig-out/bin/zigchat $out/bin/
            runHook postInstall
          '';

          meta = {
            description = "CLI tool for OpenAI chat completions";
            homepage = "https://github.com/ryoppippi/zigchat";
            license = pkgs.lib.licenses.mit;
            mainProgram = "zigchat";
          };
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
            pkgs.just
            pkgs.zon2nix
          ];

          shellHook = ''
            echo "zigchat development environment"
            zig version
          '';
        };

        apps.default = flake-utils.lib.mkApp {
          drv = zigchat;
        };
      });
}
