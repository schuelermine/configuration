{
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # basic system facts
  schuelermine.machine = {
    name = "nailbox";
    model = "framework-16-7040-amd";
  };
  nixpkgs.system = "x86_64-linux";
  system.stateVersion = "24.11";

  # disk setup
  disko.devices.disk.nvme0n1 = {
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23514Y806477";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "10G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=077" ];
          };
        };
        root = {
          name = "root-crypt";
          size = "100%";
          content = {
            type = "luks";
            name = "root";
            settings.allowDiscards = true;
            passwordFile = "/tmp/nixos-install-nailbox-disko-nvme0n1-luks-password";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };

  swapDevices = [
    {
      size = 32768;
      device = "/var/swapfile";
    }
  ];

  # kernel modules
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "thunderbolt"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];
    kernelModules = [ "kvm-amd" ];
  };

  # firmware updates
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.fwupd.enable = true;

  # switcherooctl
  services.switcherooControl.enable = true;

  # mouse quirks
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech MX Master 3S]
    MatchVendor=0x046D
    MatchProduct=0xB034
    ModelLogitechMXMaster3=0
    ModelInvertHorizontalScrolling=0
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES;
  '';
}
