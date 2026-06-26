{ inputs, lib, ... }:
let
  inherit ((import inputs.infuse-nix { inherit lib; }).v1) infuse;
  
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        cine = (import inputs.nixpkgs-stable { inherit (prev.stdenv.hostPlatform) system; }).cine;
      })
    ];
  };
}
