{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd = {
      availableKernelModules =
        [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices."nixos-root".device =
        "/dev/disk/by-uuid/79ef3c58-db49-4256-937a-8d275f90cd9e";
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5e4e5bc2-43a5-40a2-a07e-31e353f9bc90";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/B0BA-86D6";
      fsType = "vfat";
    };
    "/media/root/external-data" = {
      device = "/dev/disk/by-label/external-data";
      fsType = "ext4";
      options = [ "nofail" ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/3bcf42cc-8acd-41d5-ae32-d21d1082575a"; }];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  users = {
    groups.external-data-users = { };
    users.anselmschueler.extraGroups = [ "external-data-users" ];
  };
}
