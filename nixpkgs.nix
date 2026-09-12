{ inputs, lib, ... }:
let
  inherit ((import inputs.infuse-nix { inherit lib; }).v1) infuse;
  
in
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: prev: {
        libertinus = infuse prev.libertinus {
          __output.postInstall.__append = "\n" + "rm $out/share/fonts/truetype/LibertinusMath-Regular.ttf";
        };
      })
    ];
  };
}
