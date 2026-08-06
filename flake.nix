# DO-NOT-EDIT. Generated from nucleus declarations.
{
  description = "alpkgs";

  outputs = inputs:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [ ./nucleus/flake-module.nix ]
      ++ import ./nucleus/list-modules.nix ./modules;
  }
;

  inputs = {
  flake-parts = {
    inputs = {
      nixpkgs-lib = {
        follows = "nixpkgs";
      };
    };
    url = "github:hercules-ci/flake-parts";
  };
  nixpkgs = {
    url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };
  serena = {
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
    };
    url = "github:oraios/serena/v1.6.1";
  };
};
}
