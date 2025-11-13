{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  incus-interface = "incusbr0";
in
import ../mkMerge${"'"}.nix lib [
  {
    # nix config
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      package = pkgs.nix;
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
    environment.systemPackages = with pkgs; [
      nix-index
      nix-tree
      nix-diff
    ];
  }
  {
    # misc. system properties
    boot = {
      kernel.sysctl."kernel.sysrq" = 1;
      binfmt.emulatedSystems = [ "aarch64-linux" ];
      kernelPackages = pkgs.linuxPackages_latest;
      supportedFilesystems = [
        "ntfs"
        "exfat"
        "ext4"
      ];
    };
  }
  {
    # bootloader
    boot.loader = {
      timeout = lib.mkDefault 0;
      systemd-boot = {
        enable = lib.mkForce false;
        editor = false;
      };
    };
  }
  {
    # secure boot
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
    environment.systemPackages = with pkgs; [ sbctl ];
  }
  {
    # glossy boot
    boot = {
      initrd.systemd.enable = true;
      plymouth.enable = true;
    };
  }
  {
    # vt console
    console = {
      useXkbConfig = true;
      earlySetup = true;
    };
  }
  {
    # oom killer
    systemd = {
      oomd.enable = true;
      slices = {
        "-".sliceConfig.ManagedOOMSwap = "kill";
        user.sliceConfig.ManagedOOMMemoryPressure = "kill";
      };
    };
  }
  {
    # networking systems
    networking = {
      nftables.enable = true;
      networkmanager.enable = true;
    };
  }
  {
    # firewall
    networking.firewall =
      let
        kdeconnect = {
          from = 1714;
          to = 1764;
        };
        warpinator = {
          from = 42000;
          to = 42001;
        };
        ausweisapp = 24727;
      in
      {
        enable = true;
        interfaces.${incus-interface} = {
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
        # ^ probably necessary for virtd guests to get internet
        allowedTCPPortRanges = [
          kdeconnect
          warpinator
        ];
        allowedUDPPortRanges = [
          kdeconnect
          warpinator
        ];
        allowedTCPPorts = [ ausweisapp ];
        allowedUDPPorts = [ ausweisapp ];
      };
  }
  {
    # dns
    networking.nameservers = [
      "9.9.9.9#dns.quad9.net"
      "149.112.112.112#dns.quad9.net"
      "2620:fe::fe#dns.quad9.net"
      "2620:fe::9#dns.quad9.net"
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "2606:4700:4700::1111#one.one.one.one"
      "2606:4700:4700::1001#one.one.one.one"
    ];
    services.resolved = {
      enable = true;
      extraConfig = ''
        DNSOverTLS=true
      '';
    };
  }
  {
    # i18n
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
    services.xserver.xkb = {
      layout = "de";
      options = "eurosign:e,compose:caps";
      variant = "nodeadkeys";
    };
    environment.systemPackages = with pkgs; [
      aspellDicts.de
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science
      hunspellDicts.de-de
      hunspellDicts.en-us
      hunspellDicts.en-us-large
    ];
  }
  {
    # nm gui plugins
    networking.networkmanager.plugins = with pkgs; [ networkmanager-openconnect ];
  }
  {
    # flatpak for gui apps
    services.flatpak.enable = true;
  }
  {
    # gnome desktop environment
    services = {
      dbus.packages = [ pkgs.gcr ];
      printing.enable = true;
      libinput.enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    environment = {
      gnome.excludePackages = (
        with pkgs;
        [
          gnome-tour
          gnome-calculator
          epiphany
          totem
          geary
          gnome-calendar
        ]
      );
    };
  }
  {
    # generic desktop config
    environment.systemPackages = with pkgs; [
      amberol
      dconf-editor
      firefox-bin
      foliate
      gimp3
      gnome-sound-recorder
      inkscape
      kdePackages.breeze
      kdePackages.breeze-icons
      krita
      libreoffice-fresh
      qalculate-gtk
      qpwgraph
      rawtherapee
      showtime
      thunderbird-latest-bin
      wev
      wl-clipboard
      wezterm
    ];
  }
  /* {
    # qt
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita";
    };
  } */
  {
    # fonts
    fonts.packages = (
      (with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
      ])
      ++ (with pkgs; [
        ubuntu-classic
        ubuntu-sans
        ubuntu-sans-mono
        atkinson-hyperlegible
        atkinson-hyperlegible-next
        atkinson-hyperlegible-mono
        fira
        fira-code
        go-font
        libertinus
        terminus_font_ttf
        newcomputermodern
        inter
        source-sans
        source-serif
      ])
    );
  }
  {
    # gaming
    programs = {
      gamemode.enable = true;
      steam.enable = true;
    };
    environment.systemPackages = [
      (lib.hiPrio (
        pkgs.runCommand "steam-igpu-desktop-entry" { } ''
          mkdir -p $out/share/applications
          cp ${pkgs.steam}/share/applications/steam.desktop $out/share/applications/steam.desktop
          patch $out/share/applications/steam.desktop ${../supplementary/steam-igpu-desktop-entry.patch}
        ''
      ))
    ];
  }
  {
    # audio
    services = {
      pulseaudio.enable = false;
      pipewire = {
        enable = true;
        audio.enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        wireplumber = {
          enable = true;
          extraConfig = {
            "10-bluez"."monitor.bluez.properties" = {
              "bluez5.roles" = [
                "hsp_hs"
                "hsp_ag"
                "hfp_hf"
                "hfp_ag"
                "a2dp_sink"
                "a2dp_source"
                "bap_sink"
                "bap_source"
              ]; # enable all supported roles
            };
            "10-bluetooth-policy"."bluetooth.autoswitch-to-headset-profile" = false;
          };
        };
      };
    };
    security.rtkit.enable = true;
    environment.systemPackages = with pkgs; [ qpwgraph ];
  }
  {
    # rtkit fix
    # suggested by Discord user @goat7658
    security = {
      rtkit.args = [
        "--no-canary"
        "--rttime-usec-max=2000000"
      ];
    };
  }
  {
    # apple compat
    services = {
      usbmuxd.enable = true;
      avahi.enable = true;
      pipewire = {
        raopOpenFirewall = true;
        extraConfig.pipewire = {
          "10-airplay" = {
            "context.modules" = [
              {
                name = "libpipewire-module-raop-discover";
                # increase the buffer size against dropouts/glitches:
                # args."raop.latency.ms" = 500;
              }
            ];
          };
        };
      };
    };
  }
  {
    # incus
    networking.dhcpcd.denyInterfaces = [ incus-interface ];
    virtualisation = {
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
    };
    systemd.services."incus-dns-${incus-interface}" =
      let
        device = "sys-subsystem-net-devices-${incus-interface}.device";
      in
      {
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
    environment.systemPackages = with pkgs; [ podman-compose ];
  }
  {
    # other virtualisation
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
      };
      podman = {
        enable = true;
        dockerCompat = true;
      };
    };
    environment.systemPackages = with pkgs; [
      virtiofsd
    ];
  }
  {
    # programming
    services.nixseparatedebuginfod2.enable = true;
    environment.systemPackages = with pkgs; [
      gdb
      clang
    ];
  }
  {
    # general shell stuff
    programs = {
      fish.enable = true;
      nano = {
        enable = true;
        syntaxHighlight = true;
      };
    };
    environment.systemPackages = with pkgs; [
      bat
      btop
      chafa
      choose
      curl
      curl
      dig
      dust
      duf
      eza
      fd
      ffmpeg-full
      file
      fzf
      gdb
      git
      git-lfs
      glow
      htop
      imagemagick
      jq
      killall
      libqalculate
      lshw
      lsof
      man-pages
      moreutils
      pciutils
      powertop
      procs
      pv
      ripgrep
      rmtrash
      sd
      smartmontools
      tldr
      trash-cli
      uni
      unicode-paracode
      unixtools.xxd
      unzip
      usbutils
      wget
      whois
    ];
  }
]
