{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "lunar-bundler";
      version = "0.3.0";
      owner = "colourlabs";
      src = pkgs.fetchgit {
        url = "https://git.0x04.cc/alaestor/mirror-lunar-bundler";
        rev = "v${version}";
        hash = "sha256-jw+YcTSSbLisdNREbMuE1tLNj4W2JiybzqOn56wuOmQ=";
      };
    in
    {
      packages."${pname}" = pkgs.rustPlatform.buildRustPackage {
        inherit pname version src;
        cargoLock = {
          lockFile = "${src}/Cargo.lock";
          outputHashes."full_moon-3.0.0" = "sha256-fTsb3mGElqE9Ipx7Tiq/ZUQ5ORxbMyC8Lg03OiOtgkI=";
        };
        doCheck = false;

        meta = with pkgs.lib; {
          description = "a full lua bundler written in rust";
          homepage = "https://github.com/${owner}/${pname}";
          license = licenses.asl20;
          mainProgram = "lunar-bundler";
          platforms = platforms.unix;
        };
      };
    };
}
