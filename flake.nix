{
  description = "LogKeys Parser Flake";

  inputs = {
    nixpkgs.url = "github:glottologist/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nix-filter,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        ocaml5 = pkgs.ocaml.overrideAttrs (oldAttrs: {version = "5.0.0";});
      in rec {
        packages = {
          app = pkgs.callPackage ./logkeysparser {};
        };

        devShells = {
          ocaml = pkgs.mkShell {
            buildInputs = with pkgs; [
              mdbook
              ocaml5
              dune_3
              opam
              ocaml-ng.ocamlPackages_latest.core
              ocaml-ng.ocamlPackages_latest.merlin
              ocaml-ng.ocamlPackages_latest.cmdliner
              ocaml-ng.ocamlPackages_latest.ctypes
              ocaml-ng.ocamlPackages_latest.luv
              ocaml-ng.ocamlPackages_latest.eio
            ];
          };
        };

        defaultPackage = packages.app;
        defaultDevShell = devShells.ocaml;
      }
    );
}
