{
  pkgs,
  lib,
  machine-gui,
  configuration-trusted,
  ...
}:
{
  programs = {
    git = {
      userEmail = "mail@anselmschueler.com";
      userName = "Anselm Schüler";
      enable = true;
      delta.enable = lib.mkIf machine-gui true;
      lfs.enable = true;
      signing = lib.mkIf configuration-trusted {
        signByDefault = true;
        key = null;
      };
      extraConfig.init.defaultBranch = "b0";
    };
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
  home.packages = [ pkgs.gh ];
}
