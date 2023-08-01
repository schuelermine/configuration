{ pkgs, ... }: {
  programs = {
    git = {
      userEmail = "mail@anselmschueler.com";
      userName = "Anselm Schüler";
      enable = true;
      delta.enable = true;
      signing = {
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
}
