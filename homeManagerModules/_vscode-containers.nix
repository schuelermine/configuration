{ pkgs, ... }:
{
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-containers
  ];
}
