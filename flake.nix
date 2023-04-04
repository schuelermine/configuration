{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = { url = "github:nix-community/home-manager"; };
    nixos-repl-setup = {
      flake = false;
      url = "github:schuelermine/nixos-repl-setup";
    };
    xhmm.url = "github:schuelermine/xhmm/b0";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, xhmm, ... }:
    let
      defaultSystem = "x86_64-linux";
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      getSpecialArgs = modules:
        joinAttrs (map (module:
          if builtins.isFunction module then
            joinAttrs (map (arg:
              let matches = builtins.match "input-(.*)" arg;
              in if isNull matches then
                { }
              else
                let match = builtins.head matches;
                in { "input-${match}" = inputs.${match}; })
              (let args = builtins.functionArgs module;
              in builtins.filter (arg: !args.${arg}) (builtins.attrNames args)))
          else
            { }) modules);
      mkNixosConfigurations = builtins.mapAttrs (host:
        { system ? defaultSystem, users ? [ "anselmschueler" ]
        , modules ? [ "default" ] }:
        let
          modules' = [ self.nixosModules."hardware-${host}" ]
            ++ map (module: self.nixosModules.${module}) modules
            ++ map (user: self.nixosModules."user-${user}") users;
        in nixpkgs.lib.nixosSystem {
          inherit system;
          modules = modules';
          specialArgs = getSpecialArgs modules';
        });
      mkhomeConfigurations = users:
        joinAttrs (builtins.attrValues (builtins.mapAttrs (user:
          { modules, hosts ? builtins.attrNames self.nixosConfigurations
          , useXhmm ? true }:
          joinAttrs (map (host:
            let
              modules' = [ self.homeManagerModules."home-${user}" ]
                ++ map (module: self.homeManagerModules.${module}) modules;
            in {
              "${user}@${host}" = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  system =
                    nixosConfigurationsArgs.${host}.system or defaultSystem;
                };
                modules = modules'
                  ++ (if useXhmm then [ xhmm.homeManagerModules.all ] else [ ]);
                extraSpecialArgs = getSpecialArgs modules';
              };
            }) hosts)) users));
      nixosConfigurationsArgs = { buggeryyacht = { }; };
    in {
      nixosConfigurations = mkNixosConfigurations nixosConfigurationsArgs;
      nixosModules = {
        default = import ./nixosModules/configuration.nix;
        user-anselmschueler = import ./nixosModules/users/anselmschueler.nix;
        hardware-buggeryyacht = import ./nixosModules/hardware/buggeryyacht.nix;
      };
      homeConfigurations = mkhomeConfigurations {
        anselmschueler.modules = [
          "coding"
          "desktop"
          "git"
          "shell"
          "vscode-cpp"
          "vscode-haskell"
          "vscode-java"
          "vscode-nix"
          "vscode-python"
          "vscode-rust"
          "vscode"
        ];
      };
      homeManagerModules = joinAttrs (map (path: {
        ${builtins.head (builtins.match "(.*).nix" path)} =
          import (./homeManagerModules + "/${path}");
      }) (builtins.attrNames (builtins.readDir ./homeManagerModules)));
    };
}
