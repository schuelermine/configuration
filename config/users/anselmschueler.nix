{ pkgs, ... }: {
  virtualisation.libvirtd.enable = true;
  networking.firewall = let
    kdeconnect = {
      from = 1714;
      to = 1764;
    };
  in {
    enable = true;
    allowedTCPPortRanges = [ kdeconnect ];
    allowedUDPPortRanges = [ kdeconnect ];
  };
  programs = {
    fish.enable = true;
    steam.enable = true;
  };
  environment.shells = [ pkgs.nushell ];
  users.users.anselmschueler = {
    isNormalUser = true;
    description = "Anselm Schüler";
    extraGroups = [ "wheel" "libvirtd" ];
    passwordFile = "/etc/passwd.d/anselmschueler";
    shell = pkgs.bash;
  };
}
