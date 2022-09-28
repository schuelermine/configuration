{ pkgs, ... }: {
  virtualisation.libvirtd.enable = true;
  networking.firewall =
    let
      kdeconnect = {
        from = 1714;
        to = 1764;
      };
    in
    {
      enable = true;
      allowedTCPPortRanges = [ kdeconnect ];
      allowedUDPPortRanges = [ kdeconnect ];
    };
  programs.fish.enable = true;
  hardware.steam-hardware.enable = true;
  services.udev.packages = with pkgs; [ android-udev-rules ];
  environment.shells = [ pkgs.nushell pkgs.powershell ];
  users.users.anselmschueler = {
    isNormalUser = true;
    description = "Anselm Schüler";
    extraGroups = [ "wheel" "libvirtd" ];
    passwordFile = "/etc/passwd.d/anselmschueler";
    shell = pkgs.fish;
  };
}
