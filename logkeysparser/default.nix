{pkgs ? import <nixpkgs> {}}: let
  ocaml5 = pkgs.ocaml.overrideAttrs (oldAttrs: {version = "5.0.0";});
in
  pkgs.ocaml-ng.ocamlPackages_latest.buildDunePackage rec {
    pname = "logkeysparser";
    version = "0.1.0";
    src = ./.;
    duneVersion = "3";

    buildInputs = [
      ocaml5
    ];

    propagatedBuildInputs = with pkgs.ocaml-ng.ocamlPackages_latest; [
      dune_3
      ocaml
      cmdliner
      ctypes
      luv
      eio
    ];
  }
