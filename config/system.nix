{ pkgs, nixpkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "buggeryyacht";
  boot.supportedFilesystems = [ "ntfs" "exfat" ];
  services.flatpak.enable = true;
  nix.settings = {
    substituters = [ "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
