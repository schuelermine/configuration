{ pkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "buggeryyacht";
    firewall = {
      enable = true;
      allowedTCPPorts = [ 1716 ];  # Required for KDEConnect
    };
  };
  time.timeZone = "Europe/Berlin";
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.auto-optimise-store = true;
  };
}
