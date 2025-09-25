{
  config,
  pkgs,
  machine-name,
  ...
}:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
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
      tamasfe.even-better-toml
      myriad-dreamin.tinymist
      maximedenes.vscoq
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-deno";
          publisher = "denoland";
          version = "3.45.2";
          sha256 = "sha256-U83RWIIorJdFuhr0/l2bIo5JthTFIvedWq52dsSGOx8=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "agda-mode";
          publisher = "banacorn";
          version = "0.4.7";
          sha256 = "sha256-gNa3n16lP3ooBRvGaugTua4IXcIzpMk7jBYMJDQsY00=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "code-spell-checker-german";
          publisher = "streetsidesoftware";
          version = "2.3.1";
          sha256 = "sha256-LxgftSpGk7+SIUdZcNpL7UZoAx8IMIcwPYIGqSfVuDc=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "swift-vscode";
          publisher = "swiftlang";
          version = "2.10.0";
          sha256 = "sha256-Do4ZYe33/R9UdhFIhG/9hXgkY4SRcCJ6iaO5bTz2EU8=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "language-koka";
          publisher = "koka";
          version = "3.1.2";
          sha256 = "sha256-S4nB80zGO0mYI6y+K3fyB/BHsYU6yZCH4baY7A1M4z8=";
        };
      })
      (pkgs.vscode-utils.buildVscodeExtension rec {
        pname = vscodeExtUniqueId;
        vscodeExtPublisher = "jeanp413";
        vscodeExtName = "open-remote-ssh";
        vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
        version = "0.0.49";
        name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";
        src = pkgs.fetchurl {
          url = "https://open-vsx.org/api/${vscodeExtPublisher}/${vscodeExtName}/${version}/file/${vscodeExtUniqueId}-${version}.vsix";
          # hash = "sha256-YoeUNvxLSmy3OftZp2AnqRU+TKe3KYLt3zZ0B5XGgeE=";
          hash = "sha256-QfJnAAx+kO2iJ1EzWoO5HLogJKg3RiC3hg1/u2Jm6t4=";
          name = "${vscodeExtPublisher}-${vscodeExtName}.zip";
        };
      })
      (pkgs.vscode-utils.buildVscodeExtension rec {
        pname = vscodeExtUniqueId;
        vscodeExtPublisher = "slevesque";
        vscodeExtName = "shader";
        vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
        version = "1.1.5";
        name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";
        src = pkgs.fetchurl {
          url = "https://open-vsx.org/api/${vscodeExtPublisher}/${vscodeExtName}/${version}/file/${vscodeExtUniqueId}-${version}.vsix";
          hash = "sha256-QzqQ/5H08nJPLGwXZKWdCUUqblAe0umYSQbUtEOZNyg=";
          name = "${vscodeExtPublisher}-${vscodeExtName}.zip";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-containers";
          publisher = "ms-azuretools";
          version = "2.0.3";
          sha256 = "sha256-MAeE99XmjIjYbr72UymnkrDKsNRSjNiB1jdffKTosHQ=";
        };
      })
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "gitlab-workflow";
          publisher = "GitLab";
          version = "6.44.2";
          sha256 = "sha256-Op62F/EwhRAx+IZTKWjsa0HKPjtf1kPm3VFlFBAHC3I=";
        };
      })
    ];
    package = pkgs.vscodium;
    profiles.default.userSettings = {
      "update.mode" = "none";

      "editor.fontFamily" = "'${config.gnome.monospaceFont.name}'";
      "editor.fontSize" = config.gnome.monospaceFont.size;
      "editor.fontLigatures" = true;
      "editor.minimap.renderCharacters" = false;

      "workbench.preferredDarkColorTheme" = "Default Dark Modern";
      "workbench.preferredHighContrastLightColorTheme" = "Default Light Modern";
      "window.autoDetectColorScheme" = true;

      "editor.inlayHints.enabled" = "on";
      "editor.inlayHints.padding" = true;

      "editor.bracketPairColorization.enabled" = false;
      "editor.guides.bracketPairs" = "active";
      "editor.guides.bracketPairsHorizontal" = true;

      "editor.stickyScroll.enabled" = true;

      "editor.acceptSuggestionOnEnter" = "off";

      "files.insertFinalNewline" = true;
      "editor.insertSpaces" = true;

      "terminal.integrated.cursorStyle" = "line";

      "window.titleBarStyle" = "custom";
      "window.dialogStyle" = "native";
      "window.menuBarVisibility" = "compact";
      "window.zoomLevel" = 1;

      "scm.diffDecorationsGutterPattern" = {
        modified = false;
      };

      "diffEditor.experimental.showMoves" = true;

      "[agda]"."editor.unicodeHighlight.ambiguousCharacters" = false;

      "redhat.telemetry.enabled" = false;

      "docker.dockerPath" = "podman";

      "[typst-code]"."editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
      "[typst]"."editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
    };
  };
}
