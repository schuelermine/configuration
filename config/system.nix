{ pkgs, nixpkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "buggeryyacht";
  boot.supportedFilesystems = [ "ntfs" "exfat" ];
  services.flatpak.enable = true;
}
