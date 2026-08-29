{ ... }:{
  perSystem =
    { pkgs, system, ... }:
    let
      src = pkgs.fetchgit {
        url = "https://git.0x04.cc/alaestor/protonhax-nix";
        rev = "465f810e4055654ea10dddffd8814d6007bcea25";
        hash = "sha256-G8LjsYN4apoBJuiUily4TwiU6c3VI4UHK4Xkj92OsyQ=";
      };
    in
    {
      packages.protonhax = pkgs.callPackage "${src}/package.nix" { };
    };
}
