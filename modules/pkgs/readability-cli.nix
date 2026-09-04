{ ... }:
{
  perSystem =
    { pkgs, ... }:
    {
      # Pinned past the v2.4.5 tag: that release's package-lock.json is
      # inconsistent with its package.json (dompurify/jsdom ranges don't
      # match the locked versions), which breaks npmConfigHook. This rev
      # is the tip of main, where the lockfile was last regenerated.
      packages.readability-cli = pkgs.buildNpmPackage {
        pname = "readability-cli";
        version = "2.4.5-unstable-2026-01-07";

        src = pkgs.fetchFromGitLab {
          owner = "gardenappl";
          repo = "readability-cli";
          rev = "72c232e3cd33e91ab04b7dacfa649082b8037436";
          hash = "sha256-5a4mQbfJKAL8nOSnqnKQCjb6bJEEX59puwCw0KmddOo=";
        };

        npmDepsFetcherVersion = 2;
        npmDepsHash = "sha256-6S0HT98UYyMzlmC39wkVJZP0YavsFhfBh4ucYigUvMQ=";

        dontNpmBuild = true;

        meta = with pkgs.lib; {
          description = "Firefox Reader Mode in your terminal, using Mozilla's Readability library";
          homepage = "https://gitlab.com/gardenappl/readability-cli";
          license = licenses.gpl3Only;
          mainProgram = "readable";
          platforms = platforms.all;
        };
      };
    };
}
