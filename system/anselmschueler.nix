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
      ];
      hashedPasswordFile = "/etc/${username}.password";
    };
  };
  users.users.${username}.extraGroups = [
    "libvirtd"
  ];
  users.users.${username}.shell = pkgs.fish;
}
