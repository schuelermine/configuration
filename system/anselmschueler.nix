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
      extraGroups = [ "wheel" "gamemode" ];
      hashedPasswordFile = "/etc/${username}.password";
      shell = pkgs.fish;
    };
  };
}
