{ pkgs, ... }:
{
  programs.vscode = {
    profiles.default.extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];
    profiles.default.userSettings = {
      "[nix]"."editor.tabSize" = 2;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
    };
  };
}
