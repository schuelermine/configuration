{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    xhmm.url = "github:schuelermine/xhmm/b0";
    fenix.url = "github:nix-community/fenix";
    disko.url = "github:nix-community/disko";
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";

    infuse-nix.url = "git+https://codeberg.org/amjoseph/infuse.nix.git";
    infuse-nix.flake = false;

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # temporary lanzaboote workaround
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.rust-overlay.follows = "rust-overlay";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      xhmm,
      fenix,
      disko,
      lanzaboote,
      infuse-nix,
    }:
    let
      inherit ((import infuse-nix { inherit (nixpkgs) lib; }).v1) infuse;
      passInputsModule = {
        _module.args = { inherit inputs; };
      };
      commonSystemModules = [
        ./nixpkgs.nix
        ./machine-module-staging.nix
        passInputsModule
        disko.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
      ];
      commonHomeManagerModules = [
        ./nixpkgs.nix
        passInputsModule
        xhmm.homeManagerModules.all
      ];
      nixosSystem_ =
        originalSystemArgs:
        let
          systemArgs = infuse originalSystemArgs {
            system.__init = null;
            modules.__append = [
              {
                _module.args = {
                  inherit systemArgs;
                };
              }
            ]
            ++ commonSystemModules;
          };
        in
        (nixpkgs.lib.nixosSystem systemArgs).config.schuelermine.machine.nextStage;
      homeManagerConfiguration_ =
        originalHomeArgs:
        let
          homeArgs = infuse originalHomeArgs {
            modules.__append = commonHomeManagerModules;
          };
        in
        home-manager.lib.homeManagerConfiguration homeArgs;
    in
    {
      nixosConfigurations.nailbox = nixosSystem_ {
        modules = [
          ./system/configuration.nix
          ./system/anselmschueler.nix
          ./system/nailbox.nix
        ];
      };
      homeConfigurations."anselmschueler@nailbox" = homeManagerConfiguration_ {
        modules = [
          ./home/configuration.nix
          ./home/anselmschueler.nix
          ./home/nailbox.nix
          ./home/anselmschueler${"@"}nailbox.nix
        ];
        pkgs = self.nixosConfigurations.nailbox.pkgs;
      };
    };
}
