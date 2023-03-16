{ lib, config, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
      luks.devices = {
        nixos-root.device = "/dev/disk/by-uuid/68d3ce37-8778-49f2-8734-c4d70524347c";
        swap.device = "/dev/disk/by-uuid/fca91f96-ba9d-47d7-a6c8-3c04c0ccd843";
      };
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/448293fb-21e8-4c3b-bc82-eebac91e7574";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/disk/by-uuid/baa82ee2-1570-4f5c-821d-f5fc82f7a96f"; } ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
