{ pkgs, symlink, ... }: {
  i18n.defaultLocale = "en_GB.UTF-8";
  sound.enable = true;
  services = {
    xserver = {
      enable = true;
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
      xkbVariant = "nodeadkeys";
      libinput.enable = true;
    };
    gnome.games.enable = true;
    printing.enable = true;
  };
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    jetbrains-mono
    cascadia-code
    fira-code
    hack-font
    fira
    libertine
    ibm-plex
  ];
  environment = {
    systemPackages = with pkgs; [
      yaru-theme
      stockfish  # Provides chess engine for gnome-chess
      gnome.gnome-tweaks
      qalculate-gtk
      kitty
      firefox
      mpv
      vlc
      gnome.gnome-sound-recorder
      gimp
      libreoffice-fresh
      (symlink {
        system = "x86_64-linux";
        utils = pkgs.busybox;
        link = "/bin/gnome-terminal";
        target = "${kitty}/bin/kitty";
        target-label = "kitty";
      }) # This spoofs gnome-terminal, because currently, some unconfigurable actions in GNOME try to call a terminal but can’t find kitty.
    ];
    gnome.excludePackages = with pkgs.gnome; [
      gnome-calculator
      gnome-terminal
      epiphany
    ];
  };
}
