{
  lib,
  pkgs,
  input-nixpkgs,
  machine-gui,
  machine-weak,
  configuration-lanzaboote,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;
  boot =
    {
      initrd.systemd.enable = true;
      loader = {
        timeout = lib.mkDefault 0;
        systemd-boot = {
          enable = lib.mkDefault (!configuration-lanzaboote);
          editor = false;
        };
      };
      kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
      supportedFilesystems = lib.mkIf (!machine-weak) [
        "ntfs"
        "exfat"
        "ext4"
      ];
      plymouth.enable = lib.mkIf machine-gui true;
    }
    // lib.optionalAttrs configuration-lanzaboote {
      lanzaboote.enable = lib.mkDefault configuration-lanzaboote;
    };
  networking = {
    nameservers = [
      "1.1.1.1#cloudflare-dns.com"
      "1.0.0.1#cloudflare-dns.com"
      "2606:4700:4700::1111#cloudflare-dns.com"
      "2606:4700:4700::1001#cloudflare-dns.com"
    ];
    networkmanager.enable = true;
  };
  time.timeZone = "Europe/Berlin";
  i18n = {
    inputMethod = {
      enabled = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "ja_JP.UTF-8/UTF-8"
      "ko_KR.UTF-8/UTF-8"
    ];
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "en_GB.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_COLLATE = "en_US.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_MESSAGES = "en_US.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_NAME = "de_DE.UTF-8";
      LC_ADDRESS = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
    };
  };
  console = {
    useXkbConfig = lib.mkIf machine-gui true;
    keyMap = lib.mkIf (!machine-gui) "de-latin1-nodeadkeys";
    earlySetup = true;
  };
  security.pam.services.gdm-password.fprintAuth = false;
  services = {
    gpm.enable = lib.mkIf machine-gui true;
    flatpak.enable = lib.mkIf machine-gui true;
    dbus.packages = lib.mkIf machine-gui [ pkgs.gcr ];
    pipewire = lib.mkIf machine-gui {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
    printing.enable = lib.mkIf machine-gui true;
    switcherooControl.enable = lib.mkIf (machine-gui && !machine-weak) true;
    resolved = {
      enable = true;
      dnssec = "true";
      extraConfig = ''
        DNSOverTLS=true
      '';
    };
    libinput.enable = true;
    xserver = lib.mkIf machine-gui {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      xkb = {
        layout = "de";
        options = "eurosign:e,compose:caps";
        variant = "nodeadkeys";
      };
      excludePackages = [ pkgs.xterm ];
    };
  };
  sound.enable = lib.mkIf machine-gui true;
  hardware.pulseaudio.enable = false;
  programs = {
    nano = {
      enable = true;
      syntaxHighlight = true;
    };
    gamemode.enable = lib.mkIf (!machine-weak) true;
  };
  environment = {
    systemPackages =
      (with pkgs; [
        nix-index
        nix-tree
        nix-diff
        nix-top
        wget
        choose
        curl
        fd
        sd
        (if machine-weak then ffmpeg else ffmpeg-full)
        imagemagick
        file
        htop
        killall
        lsof
        pciutils
        ripgrep
        rmtrash
        tldr
        trash-cli
        curl
        fzf
        bat
        # rich-cli
        frogmouth
        glow
        chafa
        jq
        moreutils
        procs
        git
        git-lfs
        unicode-paracode
        uni
        libqalculate
        du-dust
        duf
        eza
        wezterm
        smartmontools
        pv
        usbutils
        whois
        dig
        lshw
      ])
      ++ lib.optionals (!machine-weak) (
        with pkgs;
        [
          man-pages
          btop
        ]
      )
      ++ lib.optionals (machine-gui && !machine-weak) (
        with pkgs;
        [
          gnome.dconf-editor
          gnome.gnome-sound-recorder
          gimp
          libreoffice-fresh
          thunderbird
          inkscape
          bottles
        ]
      )
      ++ lib.optionals machine-gui (
        with pkgs;
        [
          clapper
          qalculate-gtk
          firefox
          wl-clipboard
          xsel
          xorg.xkill
          breeze-qt5
          breeze-icons
        ]
      )
      ++ (with pkgs.aspellDicts; [
        de
        en
        en-computers
        en-science
      ])
      ++ (with pkgs.hunspellDicts; [
        de-de
        en-us
      ])
      ++ lib.optionals (!machine-weak) [ pkgs.hunspellDicts.en-us-large ]
      ++ lib.optional configuration-lanzaboote pkgs.sbctl;
    gnome.excludePackages = lib.mkIf machine-gui (
      (with pkgs; [
        gnome-tour
        gnome-console
      ])
      ++ (with pkgs.gnome; [
        gnome-calculator
        epiphany
        totem
        geary
        gnome-calendar
      ])
    );
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry.nixpkgs.to = {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = input-nixpkgs.sourceInfo.rev;
      type = "github";
    };
    nixPath = [ "nixpkgs=${input-nixpkgs}" ];
    # package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
  };
  fonts.packages = lib.mkIf machine-gui (
    (with pkgs; [
      noto-fonts
      noto-fonts-cjk
    ])
    ++ lib.optionals (!machine-weak) (
      with pkgs;
      [
        ubuntu_font_family
        atkinson-hyperlegible
        fira
        fira-code
        go-font
        libertinus
        terminus_font_ttf
        newcomputermodern
      ]
    )
  );
  qt = lib.mkIf machine-gui {
    enable = true;
    platformTheme = "qt5ct";
  };
  specialisation.NoDnsOverTlsOrDnssec.configuration.services.resolved = {
    dnssec = lib.mkForce "false";
    extraConfig = lib.mkForce "";
  };
}
