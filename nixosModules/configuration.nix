{
  lib,
  pkgs,
  config,
  machine-gui,
  machine-weak,
  configuration-lanzaboote,
  machine-vm,
  ...
}:
let
  incus-interface = "incusbr0";
in
{
  nixpkgs.config.allowUnfree = true;
  boot =
    {
      binfmt.emulatedSystems = [ "aarch64-linux" ];
      initrd.systemd.enable = true;
      loader = {
        timeout = lib.mkDefault 0;
        systemd-boot = {
          enable = lib.mkForce (!configuration-lanzaboote);
          editor = false;
        };
      };
      kernelPackages = pkgs.linuxPackages_latest;
      supportedFilesystems = lib.mkIf (!machine-weak) [
        "ntfs"
        "exfat"
        "ext4"
      ];
      plymouth.enable = lib.mkIf machine-gui true;
    }
    // lib.optionalAttrs configuration-lanzaboote {
      lanzaboote.enable = true;
    };
  networking = {
    dhcpcd.denyInterfaces = lib.mkIf (!machine-vm) [ incus-interface ];
    nftables.enable = true;
    nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
    ];
    networkmanager.enable = true;
    firewall = {
      interfaces.${incus-interface} = lib.mkIf (!machine-vm) {
        allowedTCPPortRanges = [
          {
            from = 0;
            to = 65535;
          }
        ];
        allowedUDPPortRanges = [
          {
            from = 0;
            to = 65535;
          }
        ];
      };
      trustedInterfaces = config.virtualisation.libvirtd.allowedBridges;
    };
  };
  time.timeZone = "Europe/Berlin";
  i18n = {
    inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ libpinyin ];
    };
    supportedLocales = [
      "ar_EG.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "el_GR.UTF-8/UTF-8"
      "en_GB.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "es_ES.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
      "hi_IN/UTF-8" # I have no idea why
      "ja_JP.UTF-8/UTF-8"
      "ko_KR.UTF-8/UTF-8"
      "ru_RU.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "de_DE.UTF-8";
      LC_COLLATE = "en_GB.UTF-8";
      LC_CTYPE = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MONETARY = "de_DE.UTF-8";
      LC_MESSAGES = "en_GB.UTF-8";
      LC_MEASUREMENT = "de_DE.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "de_DE.UTF-8";
      LC_TELEPHONE = "de_DE.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };
  console = {
    useXkbConfig = lib.mkIf machine-gui true;
    keyMap = lib.mkIf (!machine-gui) "de-latin1-nodeadkeys";
    earlySetup = true;
  };
  services = {
    pulseaudio.enable = false;
    usbmuxd.enable = true;
    spice-vdagentd.enable = lib.mkIf machine-vm true;
    nixseparatedebuginfod.enable = lib.mkIf (!machine-weak) true;
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
    displayManager.gdm.enable = lib.mkIf machine-gui true;
    desktopManager.gnome.enable = lib.mkIf machine-gui true;
    xserver.xkb = {
      layout = "de";
      options = "eurosign:e,compose:caps";
      variant = "nodeadkeys";
    };
  };
  virtualisation = lib.mkIf (!machine-vm) {
    waydroid.enable = false;
    incus = {
      enable = true;
      preseed = {
        networks = [
          {
            config = {
              "ipv4.nat" = true;
              "ipv6.nat" = true;
              "ipv4.address" = "auto";
              "ipv6.address" = "auto";
              "dns.mode" = "managed";
            };
            name = incus-interface;
            project = "default";
          }
        ];
        storage_pools = [
          {
            name = "default";
            driver = "btrfs";
            config.size = "100GiB";
          }
        ];
        profiles = [
          {
            devices = {
              eth0 = {
                name = "eth0";
                network = incus-interface;
                type = "nic";
              };
              root = {
                path = "/";
                pool = "default";
                type = "disk";
              };
            };
            name = "default";
          }
        ];
      };
    };
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    podman = {
      enable = true;
      dockerCompat = true;
    };
  };
  security = {
    pam.services.systemd-run0 = { };
    rtkit.args = [ "--no-canary" "--rttime-usec-max=2000000" ]; # suggested by Discord user @goat7658
  };
  systemd.slices."-".sliceConfig.ManagedOOMSwap = "kill";
  systemd.slices.user.sliceConfig.ManagedOOMMemoryPressure = "kill";
  systemd.services."incus-dns-${incus-interface}" =
    let
      device = "sys-subsystem-net-devices-${incus-interface}.device";
    in
    lib.mkIf (!machine-vm) {
      script =
        let
          incus-client = "${config.virtualisation.incus.clientPackage}/bin/incus";
          resolvectl = "${config.systemd.package}/bin/resolvectl";
        in
        ''
          set -x
          trap "${resolvectl} revert ${incus-interface}" EXIT
          IPV4="$(${incus-client} network get ${incus-interface} ipv4.address 2>/dev/null)"
          IPV6="$(${incus-client} network get ${incus-interface} ipv6.address 2>/dev/null)"
          DOMAIN="$(${incus-client} network get ${incus-interface} dns.domain 2>/dev/null)"
          ${resolvectl} dns ${incus-interface} "''${IPV4%/*}" "''${IPV6%/*}"
          ${resolvectl} domain ${incus-interface} \~"''${DOMAIN:-incus}"
          ${resolvectl} dnssec ${incus-interface} no
          ${resolvectl} dnsovertls ${incus-interface} no
          trap EXIT
          printf '%s\n' "Successfully configured DNS for Incus (interface ${incus-interface})"
        '';
      bindsTo = [ device ];
      after = [ device ];
      wantedBy = [ device ];
      serviceConfig = {
        RemainAfterExit = true;
        Type = "oneshot";
      };
    };
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
        # frogmouth
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
        smartmontools
        pv
        usbutils
        whois
        dig
        lshw
        unixtools.xxd
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
          dconf-editor
          gnome-sound-recorder
          gimp3
          libreoffice-fresh
          thunderbird-latest-bin
          inkscape
        ]
      )
      ++ lib.optionals machine-gui (
        with pkgs;
        [
          showtime
          qalculate-gtk
          firefox
          wl-clipboard
          xsel
          xorg.xkill
          kdePackages.breeze
          kdePackages.breeze-icons
          amberol
          tangram
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
      ++ lib.optional (!machine-weak) pkgs.hunspellDicts.en-us-large
      ++ lib.optional configuration-lanzaboote pkgs.sbctl
      ++ lib.optionals (!machine-vm) (with pkgs; [ virtiofsd podman-compose ]);
    gnome.excludePackages = lib.mkIf machine-gui (
      with pkgs;
      [
        gnome-music
        gnome-tour
        gnome-calculator
        epiphany
        totem
        geary
        gnome-calendar
      ]
    );
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    # package = pkgs.lix;
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
  fonts.packages = lib.mkIf machine-gui (
    (with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
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
        inter
        source-sans
        source-serif
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
