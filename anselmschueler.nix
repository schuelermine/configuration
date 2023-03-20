{ pkgs, ... }:
{
  udev.packages = with pkgs; [ android-udev-rules ];
  virtualisation.libvirtd.enable = true;
  programs.fish.enable = true;
  hardware.steam-hardware.enable = true;
  networking.firewall = let kdeconnect = {
    from = 1714;
    to = 1764;
  }; in {
    enable = true;
    allowedTCPPortRanges = [ kdeconnect ];
    allowedUDPPortRanges = [ kdeconnect ];
  };
  users = {
    mutableUsers = false;
    users.anselmschueler = {
      isNormalUser = true;
      description = "Anselm Schüler";
      extraGroups = [ "wheel" "libvirtd" ];
      passwordFile = "/etc/anselmschueler.password";
      shell = pkgs.fish;
    };
  };
}
