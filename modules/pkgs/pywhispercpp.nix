{ ... }:
{
  perSystem = { lib, pkgs, ... }: {
    packages.pywhispercpp = pkgs.python3Packages.buildPythonPackage rec {
      pname = "pywhispercpp";
      version = "1.4.1";
      pyproject = true;

      src = pkgs.fetchPypi {
        inherit pname version;
        hash = "sha256-UgzpJ1u2/IHg2qLggUSoDuAGsRehgFineGDFscnBIvQ=";
      };

      # pywhispercpp's release build uses repairwheel to bundle shared
      # libraries.  Nix instead links a position-independent static build of
      # the bundled whisper.cpp into the extension.
      postPatch = ''
        sed -i '/"repairwheel"/d' pyproject.toml
      '';

      build-system = with pkgs.python3Packages; [
        cmake
        ninja
        setuptools
        setuptools-scm
        wheel
      ];

      nativeBuildInputs = [
        pkgs.cmake
        pkgs.ninja
      ];

      # CMake is driven by pywhispercpp's setuptools build_ext command.
      dontUseCmakeConfigure = true;

      dependencies = with pkgs.python3Packages; [
        numpy
        platformdirs
        requests
        tqdm
      ];

      NO_REPAIR = "1";
      CMAKE_ARGS = "-DBUILD_SHARED_LIBS=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON -DGGML_NATIVE=OFF";

      doCheck = false;
      pythonImportsCheck = [
        "_pywhispercpp"
        "pywhispercpp"
      ];

      meta = {
        description = "Python bindings for whisper.cpp";
        homepage = "https://github.com/absadiki/pywhispercpp";
        license = lib.licenses.mit;
        platforms = lib.platforms.linux;
      };
    };
  };
}
