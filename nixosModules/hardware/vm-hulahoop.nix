{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
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
      availableKernelModules =
        [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/1c615a49-4294-4722-b28d-c970a7ac0b8e";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/1D69-BDB9";
      fsType = "vfat";
    };
  };
  swapDevices = [ ];
}
