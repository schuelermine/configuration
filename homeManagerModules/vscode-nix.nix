{ pkgs, input-nix-vscode-extensions, ... }: {
  programs.vscode = {
    extensions = with input-nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [ jnoortheen.nix-ide ];
    userSettings = {
      "[nix]"."editor.tabSize" = 2;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
    };
  };
}
