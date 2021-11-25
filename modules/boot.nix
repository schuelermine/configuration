{ pkgs, nixos-stable, ... }: {
  boot = {
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = nixos-stable.linuxPackages_latest;
    plymouth = {
      enable = true;
      theme = "fade-in";
    };
  };
}
