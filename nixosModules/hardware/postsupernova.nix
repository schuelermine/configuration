{
  lib,
  config,
  modulesPath,
  configuration-lanzaboote,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./postsupernova-disk.nix
  ];
  boot =
    {
      kernel.sysctl."vm.swappiness" = 1;
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
    }
    // lib.optionalAttrs configuration-lanzaboote {
      lanzaboote.pkiBundle = "/var/lib/sbctl";
    };
  services = {
    fwupd.enable = true;
    xserver.synaptics.palmDetect = true;
  };
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  swapDevices = [
    /* {
      size = 100000; # 64GB
      device = "/var/swapfile";
    } */
  ];
}
