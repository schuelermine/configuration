{
  lib,
  config,
  inputs,
  systemArgs,
  ...
}:
let
  inherit (inputs) nixos-hardware;
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit ((import inputs.infuse-nix { inherit (inputs.nixpkgs) lib; }).v1) infuse;
  cfg = config.schuelermine.machine;
  nextStageSystemArgs = infuse systemArgs {
    modules.__append = lib.optional (cfg.model != null) nixos-hardware.nixosModules.${cfg.model};
  };
in
{
  options.schuelermine.machine = {
    name = lib.mkOption { type = lib.types.str; };
    model = lib.mkOption { type = lib.types.nullOr lib.types.str; };
    nextStage = lib.mkOption {
      type = lib.types.raw;
      default = nixosSystem nextStageSystemArgs;
    };
  };

  config.networking.hostName = cfg.name;
}
