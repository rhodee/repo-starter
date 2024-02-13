{
  description = "{{ cookiecutter.project_slug }} developer setup";
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs@{self, flake-parts, nixpkgs, ...}: flake-parts.lib.mkFlake {inherit inputs;} {
    systems = import inputs.systems;
    imports = [
      inputs.flake-parts.flakeModules.easyOverlay
    ];

    perSystem = { self', config, pkgs, system, ... }:
      let
        overlays = [ ];

        pkgs = import nixpkgs {
          inherit system;
          overlays = overlays;
        };

        inherit (pkgs) lib;

        darwinFrameworks = with pkgs; [
          libiconv
          darwin.apple_sdk.frameworks.CoreServices
          darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
        ];
        linuxDeps = [];

        commonArgs = {
          strictDeps = true;

          buildInputs = with pkgs; []
          ++ pkgs.lib.optionals pkgs.stdenv.isDarwin darwinFrameworks
          ++ pkgs.lib.optionals pkgs.stdenv.isLinux linuxDeps;

          nativeBuildInputs = with pkgs; [ clang pkg-config ];
        };
      in
      with pkgs;
      {
        devShells = {
          default = pkgs.mkShell {
            NPM_CONFIG_REGISTRY = "https://registry.npmjs.org";

            # Things that must be available **at compile time** go here.
            nativeBuildInputs = with pkgs; [] ++commonArgs.nativeBuildInputs;

            # Things that must be available **at runtime** go here.
            buildInputs = [] ++ commonArgs.buildInputs;

            # Stuff to use inside the shell
            packages = with pkgs; [
              fd
              just
              nodePackages.pnpm
            ];
          };
        };
      };
    };
}
