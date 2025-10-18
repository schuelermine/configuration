{ inputs, ... }:
let
  inherit ((import inputs.infuse-nix { inherit (inputs.nixpkgs) lib; }).v1) infuse;
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (
        final: prev:
        infuse prev {
          jdk8.__assign = final.temurin-bin-8;
        }
      )
      (
        final: prev:
        infuse prev {
          switcheroo-control.__output.nativeBuildInputs.__append = [ prev.wrapGAppsNoGuiHook ];
        }
      )
    ];
  };
}
