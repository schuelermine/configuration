{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = (_: true);
  # nix.package = pkgs.lix;
  programs.home-manager.enable = true;
  news.display = "silent";
  home = {
    homeDirectory = "/home/anselmschueler";
    username = "anselmschueler";
  };
}
