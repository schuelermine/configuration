{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    xhmm.url = "github:schuelermine/xhmm/b0";
    fenix.url = "github:nix-community/fenix";
    disko.url = "github:nix-community/disko";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    nix-index.url = "github:nix-community/nix-index";

    infuse-nix.url = "git+https://codeberg.org/amjoseph/infuse.nix.git?rev=73c5111fdb7c0faab55bd9a19b26821639a4258e";
    infuse-nix.flake = false;

    just-the-browser.url = "github:corbindavenport/just-the-browser/8ae206e0a4145e77d488c8e2b740db795ebdf7af";
    just-the-browser.flake = false;

    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    nix-index.inputs.nixpkgs.follows = "nixpkgs";
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
      ...
    }:
    let
      inherit ((import infuse-nix { inherit (nixpkgs) lib; }).v1) infuse;
      commonSystemModules = [
        ./nixpkgs.nix
        ./machine-module-staging.nix
        disko.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
      ];
      commonHomeManagerModules = [
        ./nixpkgs.nix
        xhmm.homeManagerModules.all
      ];
      nixosSystem' =
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
            specialArgs.inputs.__init = inputs;
          };
        in
        (nixpkgs.lib.nixosSystem systemArgs).config.schuelermine.machine.nextStage;
      homeManagerConfiguration' =
        originalHomeArgs:
        let
          homeArgs = infuse originalHomeArgs {
            modules.__append = commonHomeManagerModules;
            extraSpecialArgs.inputs.__init = inputs;
          };
        in
        home-manager.lib.homeManagerConfiguration homeArgs;
    in
    {
      nixosConfigurations.nailbox = nixosSystem' {
        modules = [
          ./system/configuration.nix
          ./system/anselmschueler.nix
          ./system/nailbox.nix
          ./system/emergency-fixes.nix
        ];
      };
      homeConfigurations."anselmschueler@nailbox" = homeManagerConfiguration' {
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
