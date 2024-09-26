{
  pkgs,
  lib,
  machine-gui,
  ...
}:
{
  services.udev.packages = with pkgs; [ android-udev-rules ];
  programs.fish.enable = true;
  hardware.steam-hardware.enable = lib.mkIf machine-gui true;
  networking.firewall =
    let
      kdeconnect = {
        from = 1714;
        to = 1764;
      };
      ausweisapp = 24727;
    in
    lib.mkIf machine-gui {
      enable = true;
      allowedTCPPortRanges = [ kdeconnect ];
      allowedUDPPortRanges = [ kdeconnect ];
      allowedTCPPorts = [ ausweisapp ];
      allowedUDPPorts = [ ausweisapp ];
    };
  users = {
    mutableUsers = false;
    users.anselmschueler = {
      isNormalUser = true;
      description = "Anselm Schüler";
      extraGroups = [
        "wheel"
        "libvirtd"
        "docker"
      ];
      hashedPasswordFile = "/etc/anselmschueler.password";
      shell = pkgs.fish;
    };
  };
}
