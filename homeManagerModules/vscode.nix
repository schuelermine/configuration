{
  config,
  pkgs,
  machine-name,
  ...
}:
{
  programs.vscode = {
    enable = true;
    mutableExtensionsDir = false;
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
      sonarsource.sonarlint-vscode
      tamasfe.even-better-toml
      ms-azuretools.vscode-docker
      myriad-dreamin.tinymist
      maximedenes.vscoq
      (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
        mktplcRef = {
          name = "vscode-deno";
          publisher = "denoland";
          version = "3.36.0";
          sha256 = "sha256-xHf7cI+lCPoImdsnqBNJjT7+8UJs9tXXUm+TgiYmCdA=";
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
          name = "swift-lang";
          publisher = "sswg";
          version = "1.11.3";
          sha256 = "sha256-1zxgLPJo5U4xzJkzSlLtvAOSzW1PSya1n73Mk3GFEuo=";
        };
      })
      (pkgs.vscode-utils.buildVscodeExtension rec {
        pname = vscodeExtUniqueId;
        vscodeExtPublisher = "jeanp413";
        vscodeExtName = "open-remote-ssh";
        vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
        version = "0.0.45";
        name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";
        src = pkgs.fetchurl {
          url = "https://open-vsx.org/api/${vscodeExtPublisher}/${vscodeExtName}/${version}/file/${vscodeExtUniqueId}-${version}.vsix";
          hash = "sha256-YoeUNvxLSmy3OftZp2AnqRU+TKe3KYLt3zZ0B5XGgeE=";
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
    ];
    package = pkgs.vscodium;
    profiles.default.userSettings = {
      "update.mode" = "none";

      "editor.fontFamily" = "'${config.gnome.monospaceFont.name}'";
      "editor.fontSize" = config.gnome.monospaceFont.size;
      "editor.fontLigatures" = true;
      "editor.minimap.renderCharacters" = false;

      "sonarlint.ls.javaHome" = "${pkgs.openjdk}/lib/openjdk";
      "sonarlint.pathToNodeExecutable" = "${pkgs.nodejs}/bin/node";

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
      "docker.environment".DOCKER_HOST = "unix://${config.home.homeDirectory}/.local/share/containers/podman/machine/${machine-name}/podman.sock";

      "[typst-code]"."editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
      "[typst]"."editor.wordSeparators" = "`~!@#$%^&*()=+[{]}\\|;:'\",.<>/?";
    };
  };
}
