{ config, pkgs, ... }: {
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
    extensions = with pkgs.vscode-extensions; [
      bmalehorn.vscode-fish
      editorconfig.editorconfig
      firefox-devtools.vscode-firefox-debug
      github.vscode-pull-request-github
      mkhl.direnv
      ms-vscode.hexeditor
      redhat.vscode-xml
      redhat.vscode-yaml
      streetsidesoftware.code-spell-checker
      thenuprojectcontributors.vscode-nushell-lang
      sonarsource.sonarlint-vscode
      bungcip.better-toml
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "Nimda";
          name = "deepdark-material";
          version = "3.3.0";
          sha256 = "sha256-BcNZYLVVbXU65Gi+8snpRgbbijqDQbHeWYDyt71+F4A=";
        };
      })
    ];
    package = pkgs.vscodium;
    userSettings = {
      "update.mode" = "none";

      "editor.fontFamily" = "'${config.gnome.monospaceFont.name}'";
      "editor.fontSize" = config.gnome.monospaceFont.size;
      "editor.fontLigatures" = true;
      "editor.minimap.renderCharacters" = false;

      "sonarlint.ls.javaHome" = "${pkgs.openjdk}/lib/openjdk";
      "sonarlint.pathToNodeExecutable" = "${pkgs.nodejs}/bin/node";

      "workbench.colorTheme" = "Deepdark Material Theme | Full Black Version";

      "editor.inlayHints.enabled" = "on";

      "editor.bracketPairColorization.enabled" = true;
      "editor.stickyScroll.enabled" = true;

      "editor.acceptSuggestionOnEnter" = "off";

      "files.insertFinalNewline" = true;
      "editor.insertSpaces" = true;

      "terminal.integrated.cursorStyle" = "line";

      "window.titleBarStyle" = "custom";
      "window.dialogStyle" = "native";
      "window.menuBarVisibility" = "hidden";
      "window.zoomLevel" = 1;

      "scm.diffDecorationsGutterPattern" = { modified = false; };
    };
  };
}
