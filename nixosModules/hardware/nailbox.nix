{
  lib,
  config,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        editor = false;
      };
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };
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
          size = "512M";
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
          end = "-32G";
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
        swap = {
          name = "swap-crypt";
          size = "100%";
          content = {
            type = "luks";
            name = "swap";
            settings.allowDiscards = true;
            passwordFile = "/tmp/nixos-install-nailbox-disko-nvme0n1-luks-password";
            content.type = "swap";
          };
        };
      };
    };
  };
}
