{
  nucleus = {
    enable = true;
    description = "alpkgs";

    inputs = {
      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
      nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    };
  };
}
