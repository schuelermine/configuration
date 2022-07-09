{ pkgs, nixpkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "buggeryyacht";
  boot.supportedFilesystems = [ "ntfs" "exfat" ];
  time.timeZone = "Europe/Berlin";
  nix = {
    registry.nixpkgs.to = {
      owner = "NixOS";
      repo = "nixpkgs";
      rev = nixpkgs.sourceInfo.rev;
      type = "github";
    };
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = { auto-optimise-store = true; };
  };
  services.fwupd.enable = true;
}
