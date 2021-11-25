{ pkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking.hostName = "buggeryyacht-nixos";
  time.timeZone = "Europe/Berlin";
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    autoOptimiseStore = true;
  };
}
