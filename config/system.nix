{ pkgs, nixpkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "buggeryyacht";
  boot.supportedFilesystems = [ "ntfs" ];
  time.timeZone = "Europe/Berlin";
  nix = {
    registry.nixpkgs.flake = nixpkgs;
    nixPath = [ "nixpkgs=${nixpkgs}" ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = { auto-optimise-store = true; };
  };
}
