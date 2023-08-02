{ pkgs, ... }: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Super>t";
          command = "${pkgs.kgx}/bin/kgx --tab";
          name = "Terminal";
        };
    };
  };
  gnome = {
    extensions.enabledExtensions = with pkgs.gnomeExtensions; [ appindicator ];
    monospaceFont = {
      package = pkgs.source-code-pro;
      name = "Source Code Pro";
      size = 14;
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
    virt-manager
  ];
  fonts.fontconfig.enable = true;
}
