{ inputs, ... }:

{
  imports = [ inputs.flake-file.flakeModules.default ];

  flake-file = {
    description = "alpkgs";
    outputs = "inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)";

    inputs = {
      flake-file.url = "github:vic/flake-file";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:denful/import-tree";
      nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
  };
}
