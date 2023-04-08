{ config, pkgs, lib, machine-powerful, ... }: {
  programs.wezterm = {
    enable = lib.mkIf machine-powerful true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = wezterm.config_builder()
      config.font = wezterm.font '${config.gnome.monospaceFont.name}'
      config.font_size = ${builtins.toString config.gnome.monospaceFont.size}
      return config
    '';
  };
  dconf = {
    enable = true;
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Super>t";
          command = if machine-powerful then
            let wezterm-bin = "${config.programs.wezterm.package}/bin";
            in "${pkgs.writeShellScript "super-t" ''
              #!${pkgs.bash}/bin/sh
              ${wezterm-bin}/wezterm-gui
            ''}"
          else
            "${pkgs.kgx}/bin/kgx --tab";
          name = "Terminal";
        };
    };
  };
  gnome = {
    extensions.enabledExtensions = with pkgs.gnomeExtensions; [ appindicator ];
    monospaceFont = {
      package = pkgs.hasklig;
      name = "Hasklig";
      size = 14;
    };
  };
  qt = {
    enable = true;
    style = {
      package = pkgs.breeze-qt5;
      name = "breeze";
    };
  };
  home.packages = with pkgs; [
    spotify
    discord
    element-desktop
    signal-desktop
    apostrophe
    steam
    prismlauncher
    valent
  ];
  fonts.fontconfig.enable = true;
}
