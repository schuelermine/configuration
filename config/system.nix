{ pkgs, ... }: {
  system.stateVersion = "21.05";
  nixpkgs.config.allowUnfree = true;
  networking = {
    hostName = "buggeryyacht";
    firewall = let
      kdeconnect = {
        from = 1714;
        to = 1764;
      };
    in {
      enable = true;
      allowedTCPPorts = [ kdeconnect ];
      allowedUDPPorts = [ kdeconnect ];
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
