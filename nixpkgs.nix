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
      (
        # https://github.com/NixOS/nixpkgs/issues/475202
        # TODO: remove
        final: prev: let version = "0.5.12"; in
        infuse prev {
          wireplumber.__output = {
            version.__assign = version;
            src.__input = {
              rev.__assign = version;
              hash.__assign = "sha256-3LdERBiPXal+OF7tgguJcVXrqycBSmD3psFzn4z5krY=";
            };
          };
        }
      )
    ];
  };
}
