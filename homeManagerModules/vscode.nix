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
          publisher = "mtxr";
          name = "sqltools";
          version = "0.27.1";
          sha256 = "sha256-5XhPaxwr0yvIX0wSKDiDm+1iG947s84ULaWpxfpRcAU=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          publisher = "mtxr";
          name = "sqltools-driver-sqlite";
          version = "0.5.0";
          sha256 = "sha256-6PoPUoOTIvDgWY3WJt/upn5MRNUjMcC68Q8ti0Nkk1c=";
        };
      })
    ];
    package = pkgs.vscodium.overrideAttrs (old: {
      postInstall = old.postInstall or "" + ''
        wrapProgram $out/bin/codium --prefix PATH : ${pkgs.nodejs}/bin
      '';
    });
    userSettings = {
      "update.mode" = "none";

      "editor.fontFamily" = "'${config.gnome.monospaceFont.name}'";
      "editor.fontSize" = config.gnome.monospaceFont.size;
      "editor.fontLigatures" = true;
      "editor.minimap.renderCharacters" = false;

      "sonarlint.ls.javaHome" = "${pkgs.openjdk}/lib/openjdk";

      "workbench.colorTheme" = "Default Dark+ Experimental";

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

      "sqltools.useNodeRuntime" = true;
    };
  };
}
