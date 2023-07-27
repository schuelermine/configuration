{ lib, pkgs, input-nixpkgs, machine-smol, ... }: {
  nixpkgs.config.allowUnfree = true;
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "ntfs" "exfat" ];
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
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
    supportedLocales =
      [ "en_US.UTF-8/UTF-8" "de_DE.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" ];
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
  console.useXkbConfig = true;
  services = {
    fwupd.enable = true;
    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };
    printing.enable = true;
    switcherooControl.enable = true;
    resolved = {
      enable = true;
      dnssec = "true";
      extraConfig = ''
        DNSOverTLS=true
      '';
    };
    xserver = {
      enable = true;
      libinput.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
      xkbVariant = "nodeadkeys";
    };
  };
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  environment = {
    systemPackages = (with pkgs; [
      clapper
      qalculate-gtk
      firefox
      gnome.dconf-editor
      gnome.gnome-sound-recorder
      gimp
      libreoffice-fresh
      nix-index
      nix-tree
      nix-top
      wl-clipboard
      xsel
      xorg.xkill
      nano
      vim
      wget
      choose
      curl
      fd
      ffmpeg
      file
      htop
      killall
      lsof
      man-pages
      pciutils
      ripgrep
      rmtrash
      tldr
      trash-cli
      curl
      bat
      fzf
      glow
      jq
      moreutils
      procs
      git
      unicode-paracode
      uni
      libqalculate
      du-dust
      duf
      exa
      thunderbird
    ]) ++ (with pkgs.aspellDicts; [ de en en-computers en-science ])
      ++ (with pkgs.hunspellDicts; [ de-de en-us en-us-large ]);
    gnome.excludePackages = (with pkgs; [ gnome-tour ]) ++ (with pkgs.gnome; [
      gnome-calculator
      epiphany
      totem
      geary
      gnome-calendar
    ]);
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
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  fonts.fonts = with pkgs;
    [ noto-fonts noto-fonts-cjk ] ++ lib.optionals (!machine-smol) [
      ubuntu_font_family
      atkinson-hyperlegible
      fira
      fira-code
      go-font
      libertinus
    ];
  system.stateVersion = "22.11";
}
