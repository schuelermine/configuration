{ pkgs, config, ... }: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()
      config.font = wezterm.font("Commit Mono")
      config.font_size = ${builtins.toString config.gnome.monospaceFont.size}
      config.mouse_bindings = {
        {
          event = { Up = { streak = 1, button = "Left" }},
          mods = "NONE",
          action = wezterm.action.CompleteSelection("ClipboardAndPrimarySelection")
        },
        {
          event = { Up = { streak = 1, button = "Left" }},
          mods = "CTRL",
          action = wezterm.action.OpenLinkAtMouseCursor
        },
        {
          event = { Down = { streak = 1, button = "Left" }},
          mods = "CTRL",
          action = wezterm.action.Nop
        }
      }
      config.keys = {
        {
          key = "Enter",
          mods = "ALT",
          action = wezterm.action.DisableDefaultAssignment
        }
      }
      return config
    '';
  };
  dconf = {
    enable = true;
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Super>t";
          command = "${config.programs.wezterm.package}/bin/wezterm";
          name = "Terminal";
        };
    };
  };
  gnome = {
    extensions.enabledExtensions = with pkgs.gnomeExtensions; [ appindicator ];
    monospaceFont = {
      package = pkgs.commit-mono;
      name = "CommitMono";
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
    wineWow64Packages.full
    prismlauncher
    # valent
    virt-manager
    dino
    fractal
  ];
  fonts.fontconfig.enable = true;
  xdg.configFile."discord/settings.json".text = ''
    {
      "SKIP_HOST_UPDATE": true
    }
  '';
}
