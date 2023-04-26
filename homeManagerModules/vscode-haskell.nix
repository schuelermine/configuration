{ config, pkgs, input-nix-vscode-extensions, ... }: {
  programs = {
    vscode = {
      extensions = with input-nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        haskell.haskell
        justusadam.language-haskell
      ];
      userSettings = {
        "haskell.serverExecutablePath" =
          "${config.programs.haskell.hls.package}/bin/haskell-language-server-wrapper";
      };
    };
    haskell.hls.enable = true;
  };
}
