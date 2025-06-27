{ config, pkgs, ... }:
{
  programs = {
    vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
        haskell.haskell
        justusadam.language-haskell
      ];
      profiles.default.userSettings = {
        "haskell.serverExecutablePath" =
          "${config.programs.haskell.hls.package}/bin/haskell-language-server-wrapper";
      };
    };
    haskell.hls.enable = true;
  };
}
