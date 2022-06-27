{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    satyxinur.url = "github:SnO2WMaN/satyxinur";
    satysfi-tools.url = "github:SnO2WMaN/satysfi-tools-nix";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxinur,
    satysfi-tools,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxinur.overlay
            satysfi-tools.overlay
          ];
        };
      in {
        packages = rec {
          satydist = pkgs.satyxin.buildSatydist {
            packages = [
              "uline"
              "bibyfi"
              "fss"
              "derive"
              "algorithm"
              "chemfml"
              "ruby"
              "class-slydifi"
              "easytable"
            ];
          };
          main = pkgs.satyxin.buildDocument {
            inherit satydist;
            name = "main";
            src = ./src;
            entrypoint = "main.saty";
          };
        };
        defaultPackage = self.packages."${system}".main;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
        checks = self.packages.${system};
      }
    );
}
