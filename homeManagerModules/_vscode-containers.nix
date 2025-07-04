{ pkgs, ... }:
{
  programs.vscode.extensions = with pkgs.vscode-extensions; [
    ms-vscode-remote.remote-containers
  ];
}
