{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ./nailbox-disk.nix ];
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
        [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };
  services = {
    xserver.videoDrivers = [ "nvidia" ];
    fwupd.enable = true;
  };
  powerManagement.cpuFreqGovernor = "performance";
  hardware = {
    opengl.driSupport32Bit = true;
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
}
