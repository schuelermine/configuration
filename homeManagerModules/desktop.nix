{
  lib,
  pkgs,
  config, # FIXME remove
  machine-model,
  ...
}:
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
{
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
    ];
    monospaceFont = {
      package = pkgs.source-code-pro;
      name = "Source Code Pro";
      size = 15;
    };
  };
  home.packages = with pkgs; [
    spotify
    discord
    element-desktop
    signal-desktop
    steam
    lutris
    heroic
    wineWow64Packages.full
    prismlauncher
    virt-manager
    dino
    fractal
    blender-hip
    # zulip
    losslesscut-bin
    shortwave
    denaro
    musescore
    darktable
    freecad
  ];
  fonts.fontconfig.enable = true;
  services.easyeffects.enable = lib.mkIf (machine-model == "framework-16-7040-amd") true;
  xdg.configFile = {
    "discord/settings.json".text = ''
      {
        "SKIP_HOST_UPDATE": true
      }
    '';
    "easyeffects/output/cab-fw.json" = lib.mkIf (machine-model == "framework-16-7040-amd") {
      source = ../source/cab-fw.json;
    };
  };
  qt = {
    enable = true;
    platformTheme.name = "qtct";
  };
}
