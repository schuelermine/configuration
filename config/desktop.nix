{ pkgs, symlink, ... }: {
  i18n.defaultLocale = "en_GB.UTF-8";
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
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
    printing.enable = true;
  };
  fonts.fonts = with pkgs; [
    agave
    atkinson-hyperlegible
    cantarell-fonts
    cascadia-code
    cm_unicode
    fira
    fira
    fira-code
    fira-mono
    fixedsys-excelsior
    gentium
    go-font
    hack-font
    ibm-plex
    jetbrains-mono
    julia-mono
    lato
    league-of-moveable-type
    liberation_ttf
    liberation-sans-narrow
    libertine
    merriweather
    merriweather-sans
    montserrat
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    open-dyslexic
    open-fonts
    open-sans
    open-sans
    redhat-official-fonts
    roboto
    roboto-mono
    roboto-slab
    rubik
    siji
    source-code-pro
    source-han-code-jp
    source-han-mono
    source-han-sans
    source-han-sans-japanese
    source-han-sans-korean
    source-han-sans-simplified-chinese
    source-han-sans-traditional-chinese
    source-han-serif
    source-han-serif-japanese
    source-han-serif-korean
    source-han-serif-simplified-chinese
    source-han-serif-traditional-chinese
    source-sans
    source-sans-pro
    source-serif
    source-serif-pro
    sudo-font
    ubuntu_font_family
    unifont
    victor-mono
    vollkorn
  ];
  environment = {
    gnome.excludePackages = with pkgs; [
      gnome.gnome-calculator
      gnome.epiphany
      gnome-console
    ];
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
    ];
  };
}
