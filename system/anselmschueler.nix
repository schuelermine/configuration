{ pkgs, ... }:
let
  username = "anselmschueler";
in
{
  # user anselmschueler
  users = {
    mutableUsers = false;
    users.${username} = {
      isNormalUser = true;
      description = "Anselm Schüler";
      extraGroups = [
        "wheel"
        "libvirtd"
      ];
      hashedPasswordFile = "/etc/${username}.password";
      shell = pkgs.fish;
    };
  };
}
