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
      lfs.enable = true;
      signing = lib.mkIf configuration-trusted {
        signByDefault = true;
        key = null;
      };
      extraConfig = {
        init.defaultBranch = "b0";
        diff.external = "${pkgs.difftastic}/bin/difft";
      };
    };
    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
    };
  };
  home.packages = with pkgs; [ gh difftastic ];
}
