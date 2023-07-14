{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
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
    nix-on-droid = {
      url = "github:t184256/nix-on-droid/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, home-manager, xhmm, nixos-hardware
    , nix-on-droid, ... }:
    let
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      guard = cond: name: if cond then name else null;
      getSpecialArgs = { modules, model, smol, nixos }:
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
            { }) modules) // {
              machine-smol = smol;
              machine-model = model;
              machine-normal = true;
            };
      nixosConfigurations = builtins.mapAttrs (hostname:
        { system, usernames ? [ ], model ? null, moduleNames ? [ "default" ]
        , useNixosHardware ? false, smol ? false }:
        let
          modules = [ self.nixosModules."hardware-${hostname}" ]
            ++ map (moduleName: self.nixosModules.${moduleName}) moduleNames
            ++ map (username: self.nixosModules."user-${username}") usernames
            ++ (if useNixosHardware then
              [ nixos-hardware.nixosModules.${model} ]
            else
              [ ]) ++ [{ networking.hostName = hostname; }];
        in nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = getSpecialArgs {
            inherit modules model smol;
            normal = true;
          };
        }) nixosMachines;
      homeConfigurations = joinAttrs (builtins.attrValues (builtins.mapAttrs
        (username:
          { moduleNames, machineNames ? builtins.attrNames nixosMachines
          , useXhmm ? false }:
          joinAttrs (map (machineName:
            let
              userPresent =
                builtins.elem username nixosMachines.${machineName}.usernames;
              modules = [ self.homeManagerModules."home-${username}" ]
                ++ map (module: self.homeManagerModules.${module}) moduleNames
                ++ (if useXhmm then [ xhmm.homeManagerModules.all ] else [ ]);
            in {
              ${guard userPresent "${username}@${machineName}"} =
                home-manager.lib.homeManagerConfiguration {
                  inherit modules;
                  pkgs = import nixpkgs {
                    system = nixosMachines.${machineName}.system;
                  };
                  extraSpecialArgs = getSpecialArgs {
                    inherit modules;
                    model = nixosMachines.${machineName}.model or null;
                    smol = nixosMachines.${machineName}.smol or false;
                    normal = true;
                  };
                };
            }) machineNames)) users));
      nixosMachines.buggeryyacht = {
        model = "lenovo-legion-y530-15ich";
        system = "x86_64-linux";
        usernames = [ "anselmschueler" ];
        useNixosHardware = true;
      };
      users.anselmschueler = {
        moduleNames = [
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
        useXhmm = true;
      };
    in {
      inherit nixosConfigurations;
      inherit homeConfigurations;
      nixOnDroidConfigurations.default =
        nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [ self.nixosModules.default {
            home-manager.config = [
              ./homeManagerModules/coding.nix
              ./homeManagerModules/git.nix
              ./homeManagerModules/shell.nix
            ];
            stateVersion = "23.05";
          } ];
          extraSpecialArgs = getSpecialArgs {
            modules = "default";
            model = null;
            normal = false;
          };
        };
      nixosModules = {
        default = import ./nixosModules/configuration.nix;
        user-anselmschueler = import ./nixosModules/users/anselmschueler.nix;
        hardware-buggeryyacht = import ./nixosModules/hardware/buggeryyacht.nix;
      };
      homeManagerModules = joinAttrs (map (path: {
        ${builtins.head (builtins.match "(.*).nix" path)} =
          import (./homeManagerModules + "/${path}");
      }) (builtins.attrNames (builtins.readDir ./homeManagerModules)));
    };
}
