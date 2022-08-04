{ config, pkgs, lib, ... }: {
  boot = {
    loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    plymouth = {
      enable = true;
      font = "${pkgs.fira}/share/fonts/opentype/FiraSans-Regular.otf";
    };
  };
  systemd.targets.network-online.wantedBy = lib.mkForce [ ];
}
