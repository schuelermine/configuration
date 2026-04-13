{ inputs, lib, ... }:
let
  inherit ((import inputs.infuse-nix { inherit lib; }).v1) infuse;
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [];
  };
}
