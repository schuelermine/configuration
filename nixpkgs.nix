{ inputs, lib, ... }:
let
  inherit ((import inputs.infuse-nix { inherit lib; }).v1) infuse;
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (
        final: prev:
        infuse prev {
          switcheroo-control.__output.nativeBuildInputs.__append = [ prev.wrapGAppsNoGuiHook ];
        }
      )
    ];
  };
}
