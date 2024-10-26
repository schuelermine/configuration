{
  lib,
  pkgs,
  config,
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
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
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
      "org/gnome/desktop/media-handling".autorun-never = true;
      "org/gnome/desktop/notifications".show-in-lock-screen = false;
      "org/gnome/system/location".enabled = true;
    };
  };
  gnome = {
    extensions.enabledExtensions = with pkgs.gnomeExtensions; [
      pano
      blur-my-shell
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
    valent
    virt-manager
    dino
    apostrophe
    fractal
    # blender-hip
    zulip
  ];
  fonts.fontconfig.enable = true;
  # services.easyeffects.enable = lib.mkIf (machine-model == "framework-16-7040-amd") true;
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
