# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, nixpkgs, ... }:

{
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
    firewall = let kdeconnect = {
      from = 1714;
      to = 1764;
    }; in {
      enable = true;
      allowedTCPPortRanges = [ kdeconnect ];
      allowedUDPPortRanges = [ kdeconnect ];
    };
    hostName = "buggeryyacht";
    networkmanager.enable = true;
  };
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    packages = with pkgs; [ terminus_font ];
    font = "ter-v28b";
    keyMap = "de";
    useXkbConfig = true;
  };
  services = {
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
    udev.packages = with pkgs; [ android-udev-rules ];
    switcherooControl.enable = true;
    resolved.enable = true;      
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      libinput.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      layout = "de";
      xkbOptions = "eurosign:e";
      xkbVariant = "nodeadkeys";
    };
  };
  sound.enable = true;
  virtualisation.libvirtd.enable = true;
  programs.fish.enable = true;
  hardware = {
    steam-hardware.enable = true;
    opengl = {
      driSupport32Bit = true;
      driSupport = true;
    };
    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      nvidiaPersistenced = true;
      forceFullCompositionPipeline = true;
      prime = {
        offload.enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  users.users.anselmschueler = {
    isNormalUser = true;
    description = "Anselm Schüler";
    extraGroups = [ "wheel" "libvirtd" ];
    passwordFile = "/etc/anselmschueler.password";
    shell = pkgs.fish;
  };
  powerManagement.cpuFreqGovernor = "performance";
  environment = {
    systemPackages = (with pkgs; [
      qalculate-gtk
      firefox
      gnome.gnome-sound-recorder
      gimp
      libreoffice-fresh
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
      unicode-paracode
      libqalculate
      du-dust
      exa
    ]) ++ (with pkgs.aspellDicts; [
      de en en-computers en-science
    ]) ++ (with pkgs.hunspellDicts; [
      de-de en-us en-us-large
    ]);
    gnome.excludePackages = (with pkgs; [
      gnome-tour
    ]) ++ (with pkgs.gnome; [
      gnome.gnome-calculator
      gnome.epiphany
    ]);
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    registry.nixpkgs.to = {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = nixpkgs.sourceInfo.rev;
      type = "github";
    };
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    package = pkgs.nixUnstable;
    settings = {
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
  ];
  system.stateVersion = "22.11";
}

