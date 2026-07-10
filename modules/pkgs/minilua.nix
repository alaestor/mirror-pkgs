{ ... }:
{
  perSystem = { pkgs, ... }: {
    packages.minilua = pkgs.python3.pkgs.buildPythonPackage {
      pname = "minilua";
      version = "1.1.0";

      src = pkgs.fetchFromGitHub {
        owner = "aradooo";
        repo = "MiniLua";
        rev = "v1.1.0";
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
        license = licenses.mit;
      };
    };
  };
}
