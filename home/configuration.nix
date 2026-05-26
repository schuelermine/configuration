{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
# TODO: clean up
import ../mkMerge${"'"}.nix lib [
  {
    programs.home-manager.enable = true;
    news.display = "silent";
    nix.package = pkgs.nix;
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
      rust.customToolchain.toolchainPackage =
        inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.stable.toolchain;
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
    programs.kitty = {
      enable = true;
      package = null;
      font = {
        name = "${config.gnome.monospaceFont.name}";
        size = config.gnome.monospaceFont.size;
      };
      shellIntegration.enableFishIntegration = true;
      settings = {
        cursor_trail = 100;
        cursor_trail_start_threshold = 4;
        scrollback_lines = 100000;
        scrollback_pager_history_size = 2000; # 2 GB
        scrollback_fill_enlarged_window = true;
        touch_scroll_multiplier = 5.0;
        underline_hyperlinks = "always"; # only applies to OSC 8 hyperlinks, not detected URLs
        repaint_delay = 5; # half default, ~200fps
        input_delay = 2; # default: 3
        paste_actions = "quote-urls-at-prompt,confirm,confirm-if-large";
      };
      # using raw config text for this because the home-manager module's bindings option looks awful
      extraConfig = ''
        # do not use ctrl+shift+arrows for tab switching
        map ctrl+shift+right
        map ctrl+shift+left

        # reuse cwd for new tabs
        map ctrl+shift+t new_tab_with_cwd

        # do not open links on left click
        mouse_map left       click ungrabbed         mouse_handle_click selection prompt
        mouse_map shift+left click ungrabbed,grabbed mouse_handle_click selection prompt

        # open link on ctrl+click
        mouse_map ctrl+left release grabbed,ungrabbed mouse_handle_click link
        mouse_map ctrl+left press   grabbed           discard_event

        # unmap unused link bindings
        mouse_map ctrl+shift+left release grabbed,ungrabbed

        # use alt+click for rectangle select
        mouse_map alt+left       press       ungrabbed         mouse_selection rectangle
        mouse_map alt+shift+left press       ungrabbed,grabbed mouse_selection rectangle
        mouse_map alt+left       triplepress ungrabbed         mouse_selection line_from_point
        mouse_map alt+shift+left press       ungrabbed,grabbed mouse_selection line_from_point

        # unmap unused rectangle select bindings
        mouse_map ctrl+alt+left       press       ungrabbed
        mouse_map ctrl+shift+alt+left press       ungrabbed,grabbed
        mouse_map ctrl+alt+left       triplepress ungrabbed
      '';
    };
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
      plugins = with pkgs.obs-studio-plugins; [ obs-vaapi obs-vkcapture ];
    };
    dconf = {
      enable = true;
      settings = {
        "org/gnome/shell".always-show-log-out = true;
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        ];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "${pkgs.kitty}/bin/kitty";
          name = "Terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys".email = [ "<Super>e" ];
        "org/gnome/settings-daemon/plugins/media-keys".www = [ "<Super>b" ];
        "org/gnome/settings-daemon/plugins/media-keys".home = [ "<Super>f" ];
        "org/gnome/shell".favorite-apps = [
          "firefox.desktop"
          "thunderbird.desktop"
          "org.gnome.Nautilus.desktop"
        ];
        "org/gnome/mutter" = {
          edge-tiling = true;
          attach-modal-dialogs = true;
        };
        "org/gnome/shell/extensions/appindicator".icon-size = 20;
        "org/gnome/desktop/media-handling".autorun-never = true;
        "org/gnome/desktop/notifications".show-in-lock-screen = true;
        "org/gnome/system/location".enabled = true;
        "org/gnome/Console".ignore-scrollback-limit = true;
      };
    };
    services.kdeconnect.enable = true;
    gnome = {
      extensions.enabledExtensions = with pkgs.gnomeExtensions; [
        copyous
        blur-my-shell
        appindicator
        night-theme-switcher
        advanced-alttab-window-switcher
      ];
      monospaceFont = {
        package = pkgs.libertinus;
        name = "Libertinus Mono";
        size = 14;
      };
    };
    home.packages = (
      with pkgs;
      [
        discord
        deltachat-desktop
        telegram-desktop
        spotify
        element-desktop
        signal-desktop
        # lutris
        heroic
        wineWow64Packages.full
        prismlauncher
        virt-manager
        dino
        fractal
        # zulip
        losslesscut-bin
        shortwave
        musescore
        darktable
        freecad
        amberol
        foliate
        gnome-podcasts
        audacity
        pkgsRocm.blender
        qbittorrent
        ausweisapp
        xpano
        keypunch
      ]
    );
    fonts.fontconfig.enable = true;
    xdg.configFile = {
      "discord/settings.json".text = ''
        {
          "SKIP_HOST_UPDATE": true
        }
      '';
    };
    /*
      qt = {
        enable = true;
        platformTheme.name = "adwaita";
        style.name = "adwaita";
      };
    */
  }
  {
    programs = {
      git = {
        maintenance = {
          enable = true;
          repositories = [
            "/home/anselmschueler/Documents/git/github.com/NixOS/nixpkgs"
            "/home/anselmschueler/Documents/git/git.kernel.org/pub/scm/linux/kernel/git/stable/linux"
            "/home/anselmschueler/Documents/git/git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux"
          ];
        };
        settings = {
          user.email = "mail@anselmschueler.com";
          user.name = "Anselm Schüler";
          init.defaultBranch = "b0";
        };
        enable = true;
        lfs.enable = true;
        signing = {
          # TODO: extract
          format = "openpgp";
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
      fzf.enable = true;
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
        config = builtins.readFile ../supplementary/nanorc;
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
          mv = "mv -i";
          cp = "cp -i";
          yh = "cdh";
        };
        prompt = builtins.readFile ../supplementary/prompt.fish;
        interactiveShellInit = builtins.concatStringsSep "\n" (
          map builtins.readFile [
            ../supplementary/colors.fish
            ../supplementary/features.fish
            ../supplementary/commands.fish
            ../supplementary/abbr.fish
            ../supplementary/fixups.fish
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
    programs.vscodium = {
      profiles.default.extensions = with pkgs.vscode-extensions; [
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
      vscodium = {
        profiles.default.userSettings = {
          "haskell.serverExecutablePath" =
            "${config.programs.haskell.hls.package}/bin/haskell-language-server-wrapper";
        };
      };
      haskell.hls.enable = true;
    };
  }
  {
    programs.vscodium = {
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
    programs.vscodium = {
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
    programs.vscodium = {
      profiles.default.userSettings = {
        "[nix]"."editor.tabSize" = 2;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.serverSettings".nil.formatting.command = [ "${pkgs.nixfmt}/bin/nixfmt" ];
      };
    };
  }
  {
    programs.vscodium = {
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
      vscodium = {
        profiles.default.userSettings = {
          "[rust]"."editor.formatOnSave" = true;
          "rust-analyzer.server.path" = "${config.programs.rust.rust-analyzer.package}/bin/rust-analyzer";
        };
      };
      rust.exposeRustSrcLocation = "${inputs.fenix.packages.${pkgs.stdenv.hostPlatform.system}.stable.rust-src
      }";
    };
  }
  {
    programs.vscodium = {
      enable = true;
      mutableExtensionsDir = true;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        myriad-dreamin.tinymist
        (pkgs.vscode-utils.buildVscodeExtension rec {
          pname = vscodeExtUniqueId;
          vscodeExtPublisher = "jeanp413";
          vscodeExtName = "open-remote-ssh";
          vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";
          version = "0.0.49";
          name = "${vscodeExtPublisher}-${vscodeExtName}-${version}";
          src = pkgs.fetchurl {
            url = "https://open-vsx.org/api/${vscodeExtPublisher}/${vscodeExtName}/${version}/file/${vscodeExtUniqueId}-${version}.vsix";
            hash = "sha256-QfJnAAx+kO2iJ1EzWoO5HLogJKg3RiC3hg1/u2Jm6t4=";
            name = "${vscodeExtPublisher}-${vscodeExtName}.vsix";
          };
        })
      ];
      profiles.default.userSettings = {
        "update.mode" = "none";

        "editor.fontFamily" = "'${config.gnome.monospaceFont.name}'";
        "editor.fontSize" = config.gnome.monospaceFont.size;
        "editor.fontLigatures" = true;
        "editor.minimap.renderCharacters" = false;

        "workbench.preferredDarkColorTheme" = "Dark 2026";
        "workbench.preferredLightColorTheme" = "Light 2026";
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
  {
    programs.vscodium.profiles.default.extensions =
      let
        ignored = [
          {
            name = "tinymist";
            publisher = "myriad-dreamin";
          }
          {
            name = "vscode-lldb";
            publisher = "vadimcn";
          }
        ];
      in
      lib.map (ext: pkgs.vscode-utils.buildVscodeMarketplaceExtension { mktplcRef = ext; }) (
        lib.filter (
          { name, publisher, ... }: !lib.elem { inherit name publisher; } ignored
        ) (import ./extensions.nix).extensions
      );
  }
  {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*".SetEnv.TERM = "xterm-256color";
    };
  }
  {
    home.packages = with pkgs; [ hyperrogue ];
  }
]
