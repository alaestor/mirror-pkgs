{ ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      pname = "cppfront";
      version = "0.8.1";
    in
    {
      packages.cppfront = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchFromGitHub {
          owner = "hsutter";
          repo = pname;
          rev = "v${version}";
          sha256 = "sha256-QYjon2EpNexYa2fl09AePkpq0LkRVBOQM++eldcVMvI=";
        };

        buildPhase = ''
          g++ ./source/cppfront.cpp -std=c++20 -o cppfront
        '';

        installPhase = ''
          mkdir -p $out/bin
          cp cppfront $out/bin
          cp -r include $out
        '';

        meta = with pkgs.lib; {
          description = "A compiler from Cpp2 to Cpp1";
          homepage = "https://github.com/hsutter/cppfront";
          # SPDX: Apache-2.0 WITH LLVM-exception
          license = with licenses; (WITH asl20 llvm-exception);
          maintainers = [ ];
          platforms = platforms.all;
        };
      };
    };
}
