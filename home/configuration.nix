{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
# TODO: clean up
lib.mkMerge [
  {
    programs.home-manager.enable = true;
    news.display = "silent";
    nix.package = pkgs.nix;
  }
  {
    programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-vscode-remote.remote-containers
    ];
  }
  {
    programs = {
      haskell = {
        ghc = {
          enable = true;
          ghciConfig = ''
            :set +m
          '';
        };
        cabal.enable = true;
        stack.enable = true;
      };
      rust.customToolchain.toolchainPackage = inputs.fenix.packages.${pkgs.system}.complete.toolchain;
      python = {
        enable = true;
        mypy.enable = true;
      };
    };
    home.packages = with pkgs; [
      agda
      clang
      koka
    ];
  }
  {
    /*
      TODO let
        patch-commit-mono-script = pkgs.writeText "patch-commit-mono-script.py" ''
          from fontforge import open as ffopen
          from sys import argv
          font = ffopen(argv[1], 32)
          target_features =
          for lookup in font.gsub_lookups:
            match font.getLookupInfo(lookup):
              case _, _, (("cv08", _, _),):
                for subtable in font.getLookupSubtables(lookup):

        '';
        patched-commit-mono =
          pkgs.runCommand "patched-${pkgs.commit-mono.name}" { nativeBuildInputs = [ pkgs.fontforge ]; }
            ''
              cp -r ${pkgs.commit-mono} $out
              for file in $out/share/fonts/{opentype,truetype}/*
              do
                chmod +w $file
                fontforge -script ${patch-commit-mono-script} $file
              done
            '';
      in
    */
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-vaapi ];
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "${pkgs.gnome-console}/bin/kgx";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys".email = [ "<Super>e" ];
        "org/gnome/settings-daemon/plugins/media-keys".www = [ "<Super>b" ];
        "org/gnome/settings-daemon/plugins/media-keys".home = [ "<Super>f" ];
        "org/gnome/shell".favorite-apps = [
          "firefox.desktop"
          "thunderbird.desktop"
        ];
        "org/gnome/mutter" = {
          edge-tiling = true;
          attach-modal-dialogs = true;
        };
        "org/gnome/desktop/interface".cursor-size = 32;
        "org/gnome/desktop/interface".text-scaling-factor = 1.25;
        "org/gnome/shell/extensions/appindicator".icon-size = 20;
        "org/gnome/desktop/media-handling".autorun-never = true;
        "org/gnome/desktop/notifications".show-in-lock-screen = false;
        "org/gnome/system/location".enabled = true;
        "org/gnome/Console".ignore-scrollback-limit = true;
      };
    };
    gnome = {
      extensions.enabledExtensions = with pkgs.gnomeExtensions; [
        pano
        blur-my-shell
        gsconnect
        appindicator
        night-theme-switcher
        advanced-alttab-window-switcher
      ];
      monospaceFont = {
        package = pkgs.source-code-pro;
        name = "Source Code Pro";
        size = 15;
      };
    };
    home.packages =
      (with pkgs; [
        discord
        spotify
        element-desktop
        signal-desktop
        lutris
        heroic
        wineWow64Packages.full
        prismlauncher
        virt-manager
        dino
        fractal
        zulip
        losslesscut-bin
        shortwave
        musescore
        darktable
        freecad
        amberol
        krita
        foliate
        gnome-podcasts
        audacity
        blender-hip
        qbittorrent
        ausweisapp
      ])
      ++ [
        
      ];
    fonts.fontconfig.enable = true;
    xdg.configFile = {
      "discord/settings.json".text = ''
        {
          "SKIP_HOST_UPDATE": true
        }
      '';
    };
    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style.name = "adwaita";
    };
  }
  {
    programs = {
      git = {
        settings = {
          user.email = "mail@anselmschueler.com";
          user.name = "Anselm Schüler";
          init.defaultBranch = "b0";
        };
        enable = true;
        lfs.enable = true;
        signing = {
          # TODO: extract
          signByDefault = true;
          key = null;
        };
      };
      gh = {
        enable = true;
        gitCredentialHelper.enable = true;
      };
      difftastic = {
        git.enable = true;
        enable = true;
      };
    };
    home.packages = with pkgs; [ gh ];
  }
  {
    services.gpg-agent = {
      pinentry.package = pkgs.pinentry-gnome3;
      enable = true;
    };
    programs = {
      bat = {
        enable = true;
        config.style = "numbers,changes,rule,snip";
      };
      gpg.enable = true;
      less = {
        enable = true;
        options = {
          chop-long-lines = true;
          RAW-CONTROL-CHARS = true;
          LONG-PROMPT = true;
          use-color = true;
        };
      };
      nano = {
        enable = true;
        config = ''
          set smarthome
          set boldtext
          set tabstospaces
          set historylog
          set positionlog
          set softwrap
          set zap
          set atblanks
          set autoindent
          set linenumbers
          set cutfromcursor
          set mouse
          set indicator
          set afterends
          set stateflags
          set tabsize 4
        '';
      };
      zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd"
          "y"
        ];
      };
      direnv.enable = true;
      fish = {
        enable = true;
        functions.man = ''
          COLUMNS=(math "min($COLUMNS, 95)") command man $argv
        '';
        shellAbbrs = {
          c = "bat";
          x = "eza --group-directories-first";
        };
        prompt = builtins.readFile ../supplementary/prompt.fish;
        interactiveShellInit = builtins.concatStringsSep "\n" (
          map builtins.readFile [
            ../supplementary/colors.fish
            ../supplementary/features.fish
            ../supplementary/commands.fish
            ../supplementary/abbr.fish
          ]
        );
      };
    };
    home = {
      packages = with pkgs; [
        haskellPackages.ret
        asciinema
        powershell
        nushell
        typst
        # hatch
        uv
        fastfetch
        rich-cli
        frogmouth
      ];
      sessionVariables.EXA_COLORS = "xx=2";
    };
    xdg.configFile."uv/uv.toml".text = ''
      python-preference = "only-system"
    '';
  }
  {
    programs.vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
        llvm-vs-code-extensions.vscode-clangd
        ms-vscode.cmake-tools
        ms-vscode.makefile-tools
        twxs.cmake
        vadimcn.vscode-lldb
      ];
      profiles.default.userSettings = {
        "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
        "cmake.cmakePath" = "${pkgs.cmake}/bin/cmake";
        "makefile.makePath" = "${pkgs.gnumake}/bin/make";
      };
    };
  }
  {
    programs = {
      vscode = {
        profiles.default.extensions = with pkgs.vscode-extensions; [
          haskell.haskell
          justusadam.language-haskell
        ];
        profiles.default.userSettings = {
          "haskell.serverExecutablePath" =
            "${config.programs.haskell.hls.package}/bin/haskell-language-server-wrapper";
        };
      };
      haskell.hls.enable = true;
    };
  }
  {
    programs.vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
        redhat.java
        vscjava.vscode-java-debug
        vscjava.vscode-java-dependency
        vscjava.vscode-java-test
        vscjava.vscode-maven
      ];
      profiles.default.userSettings = {
        "java.configuration.runtimes" = [
          {
            "default" = true;
            "name" = "JavaSE-17";
            "path" = "${pkgs.openjdk}/lib/openjdk";
          }
        ];
        "java.jdt.ls.java.home" = "${pkgs.openjdk}/lib/openjdk";
        "files.exclude" = {
          "**/.classpath" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.factorypath" = true;
        };
      };
    };
  }
  {
    programs.vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
        redhat.java
        vscjava.vscode-java-debug
        vscjava.vscode-java-dependency
        vscjava.vscode-java-test
        vscjava.vscode-maven
      ];
      profiles.default.userSettings = {
        "java.configuration.runtimes" = [
          {
            "default" = true;
            "name" = "JavaSE-17";
            "path" = "${pkgs.openjdk}/lib/openjdk";
          }
        ];
        "java.jdt.ls.java.home" = "${pkgs.openjdk}/lib/openjdk";
        "files.exclude" = {
          "**/.classpath" = true;
          "**/.project" = true;
          "**/.settings" = true;
          "**/.factorypath" = true;
        };
      };
    };
  }
  {
    programs.vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [ jnoortheen.nix-ide ];
      profiles.default.userSettings = {
        "[nix]"."editor.tabSize" = 2;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
      };
    };
  }
  {
    programs.vscode = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
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
      profiles.default.userSettings = {
        "mypy.dmypyExecutable" = "${config.programs.python.mypy.package}/bin/dmypy";
        "python.defaultInterpreterPath" = "${config.programs.python.package}/bin/python";
        "python.formatting.provider" = "black";
        "python.formatting.blackPath" = "${pkgs.black}/bin/black";
      };
    };
  }
  {
    programs = {
      vscode = {
        profiles.default.extensions = with pkgs.vscode-extensions; [ rust-lang.rust-analyzer ];
        profiles.default.userSettings = {
          "[rust]"."editor.formatOnSave" = true;
          "rust-analyzer.server.path" = "${config.programs.rust.rust-analyzer.package}/bin/rust-analyzer";
        };
      };
      rust.exposeRustSrcLocation = "${inputs.fenix.packages.${pkgs.system}.latest.rust-src}";
    };
  }
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
        # streetsidesoftware.code-spell-checker
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
        /* (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "code-spell-checker-german";
            publisher = "streetsidesoftware";
            version = "2.3.1";
            sha256 = "sha256-LxgftSpGk7+SIUdZcNpL7UZoAx8IMIcwPYIGqSfVuDc=";
          };
        }) */
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

        "workbench.secondarySideBar.defaultVisibility" = "hidden";

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
]
