{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    nixos-hardware.url = "github:schuelermine/nixos-hardware/framework-16-remove-quirks";
    home-manager.url = "github:nix-community/home-manager";
    xhmm.url = "github:schuelermine/xhmm/b0";
    fenix.url = "github:nix-community/fenix";
    disko.url = "github:nix-community/disko";
    lanzaboote.url = "github:nix-community/lanzaboote/v1.0.0";
    nix-index.url = "github:nix-community/nix-index";

    infuse-nix.url = "git+https://codeberg.org/amjoseph/infuse.nix.git?rev=73c5111fdb7c0faab55bd9a19b26821639a4258e";
    infuse-nix.flake = false;

    just-the-browser.url = "github:corbindavenport/just-the-browser/e98f59c8fb73e8e5f0d5cb9c13e2a2edc3335daa";
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
      nixosConfigurations.opalvinyard = nixosSystem' {
        modules = [
          ./system/configuration.nix
          ./system/anselmschueler.nix
          ./system/opalvinyard.nix
          ./system/emergency-fixes.nix
        ];
      };
      homeConfigurations."anselmschueler@opalvinyard" = homeManagerConfiguration' {
        modules = [
          ./home/configuration.nix
          ./home/anselmschueler.nix
          ./home/opalvinyard.nix
          ./home/anselmschueler${"@"}opalvinyard.nix
        ];
        pkgs = self.nixosConfigurations.opalvinyard.pkgs;
      };
    };
}
