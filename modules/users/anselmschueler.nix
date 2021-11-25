{ pkgs, ... }: {
  virtualisation.libvirtd.enable = true;
  programs.fish.enable = true;
  programs.steam.enable = true;
  users.users.anselmschueler = {
    isNormalUser = true;
    description = "Anselm Schüler";
    extraGroups = [ "wheel" "libvirtd" ];
    passwordFile = "/etc/passwd.d/anselmschueler";
    shell = pkgs.fish;
  };
}
