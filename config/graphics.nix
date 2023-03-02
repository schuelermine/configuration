{ pkgs, ... }: {
  services = {
    switcherooControl.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };
  hardware = {
    opengl = {
      driSupport32Bit = true;
      driSupport = true;
    };
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
