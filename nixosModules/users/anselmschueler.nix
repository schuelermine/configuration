{ pkgs, lib, machine-weak, machine-gui, ... }:
{
  services.udev.packages = with pkgs; [ android-udev-rules ];
  virtualisation = lib.mkIf (!machine-weak) {
    docker.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };
  programs.fish.enable = true;
  hardware.steam-hardware.enable = lib.mkIf machine-gui true;
  networking.firewall = let kdeconnect = {
    from = 1714;
    to = 1764;
  }; in lib.mkIf machine-gui {
    enable = true;
    allowedTCPPortRanges = [ kdeconnect ];
    allowedUDPPortRanges = [ kdeconnect ];
  };
  users = {
    mutableUsers = false;
    users.anselmschueler = {
      isNormalUser = true;
      description = "Anselm Schüler";
      extraGroups = [ "wheel" "libvirtd" "docker" ];
      hashedPasswordFile = "/etc/anselmschueler.password";
      shell = pkgs.fish;
    };
  };
}
