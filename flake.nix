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
  pyproject-build-systems = {
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
      pyproject-nix = {
        follows = "pyproject-nix";
      };
      uv2nix = {
        follows = "uv2nix";
      };
    };
    url = "github:pyproject-nix/build-system-pkgs";
  };
  pyproject-nix = {
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
    };
    url = "github:pyproject-nix/pyproject.nix";
  };
  serena = {
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
    };
    url = "github:oraios/serena/v1.6.1";
  };
  uv2nix = {
    inputs = {
      nixpkgs = {
        follows = "nixpkgs";
      };
      pyproject-nix = {
        follows = "pyproject-nix";
      };
    };
    url = "github:pyproject-nix/uv2nix";
  };
};
}
