{
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "thunderbolt"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
    lanzaboote.pkiBundle = "/etc/secureboot";
  };
  services = {
    fwupd.enable = true;
    xserver.synaptics.palmDetect = true;
  };
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
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
          end = "100%";
          content = {
            type = "luks";
            name = "root";
            settings.allowDiscards = true;
            passwordFile = "/tmp/nixos-install-nailbox-disko-nvme0n1-luks-password";
            content = {
              type = "btrfs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
  environment.etc."libinput/local-overrides.quirks".text = ''
    [Logitech MX Master 3S]
    MatchVendor=0x046D
    MatchProduct=0xC548
    AttrEventCode=-REL_WHEEL_HI_RES;-REL_HWHEEL_HI_RES;
  '';
}
