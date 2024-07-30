{ config, pkgs, ... }:
{
  programs.vscode = {
    extensions = with pkgs.vscode-extensions; [
      matangover.mypy
      ms-python.python
      ms-pyright.pyright
      ms-toolsai.jupyter
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "black-py";
          publisher = "mikoz";
          version = "1.0.3";
          sha256 = "sha256-88Il9kfSahmexBYUCMfA0mlLCel+9JSwkssBcuEFrt4=";
        };
      })
    ];
    userSettings = {
      "mypy.dmypyExecutable" = "${config.programs.python.mypy.package}/bin/dmypy";
      "python.defaultInterpreterPath" = "${config.programs.python.package}/bin/python";
      "python.formatting.provider" = "black";
      "python.formatting.blackPath" = "${pkgs.black}/bin/black";
    };
  };
}
