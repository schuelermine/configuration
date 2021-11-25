{ pkgs, ... }: {
  i18n.defaultLocale = "en_GB.UTF-8";
  hardware.pulseaudio.enable = true;
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
    gnome = {
      core-developer-tools.enable = true;
      games.enable = true;
    };
    printing.enable = true;
  };
  environment = {
    systemPackages = with pkgs; [
      gnome.gnome-tweaks
      qalculate-gtk
      kitty
      firefox
      mpv
      vlc
      gnome.gnome-sound-recorder
      gimp
      libreoffice-fresh
    ];
    gnome.excludePackages = with pkgs.gnome; [
      gnome-calculator
      gnome-terminal
      epiphany
    ];
  };
}
