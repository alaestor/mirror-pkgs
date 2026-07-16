{ ... }:
{
  perSystem =
    { pkgs, fetchFromCodeberg, ... }:
    let
      pname = "minilua";
      version = "1.1.0";
      owner = "alaestor";
      repo = "fork-MiniLua";
    in
    {
      packages.minilua = pkgs.python3.pkgs.buildPythonPackage {
        inherit pname version;

        src = pkgs.fetchFromCodeberg {
          inherit owner repo;
          rev = "v${version}";
          hash = "sha256-vfE2mCe4QTdwowIAoCV6e9u5Xzj1EJEfemllIq6D1Xs=";
        };

        pyproject = true;

        build-system = with pkgs.python3.pkgs; [
          setuptools
          wheel
        ];

        dependencies = with pkgs.python3.pkgs; [
          click
          colorama
        ];

        doInstallCheck = true;

        installCheckPhase = ''
          $out/bin/minilua --version
        '';

        meta = with pkgs.lib; {
          description = "MiniLua";
          #homepage = "https://github.com/aradooo/MiniLua"; -- vanished?
          homepage = "https://codeberg.org/alaestor/fork-MiniLua";
          license = licenses.mit;
        };
      };
    };
}
