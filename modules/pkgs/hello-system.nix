{ ... }:
{
  perSystem = { pkgs, system, ... }: {
    packages.hello-system = pkgs.writeShellScriptBin "hello_system" ''
      echo Hello ${system}
    '';
  };
}
