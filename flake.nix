{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-vscode-lldb.url =
      "github:schuelermine/nixpkgs/patch/vscode-extensions.vadimcn.vscode-lldb/remove-custom-lldb";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager.url = "github:nix-community/home-manager";
    nixos-repl-setup = {
      flake = false;
      url = "github:schuelermine/nixos-repl-setup";
    };
    xhmm.url = "github:schuelermine/xhmm/b0";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dwarffs.url = "github:edolstra/dwarffs";
  };
  outputs = inputs@{ self, nixpkgs, home-manager, xhmm, nixos-hardware, dwarffs, ... }:
    let
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      guard = cond: name: if cond then name else null;
      getSpecialArgs = { system, model, smol, name }:
        {
          machine-smol = smol;
          machine-model = model;
          machine-name = name;
          source-flake = self;
          inherit system;
        } // joinAttrs
        (map (inputName: { "input-${inputName}" = inputs.${inputName}; })
          (builtins.attrNames inputs)) // joinAttrs (map (nixpkgsVersionName: {
            "${nixpkgsVersionName}" =
              import inputs.${nixpkgsVersionName} { inherit system; };
          }) [ "nixpkgs" "nixpkgs-vscode-lldb" ]);
      nixosConfigurations = builtins.mapAttrs (hostname:
        { system, usernames ? [ ], model ? null, moduleNames ? [ "default" ]
        , useNixosHardware ? false, useDwarffs ? false, smol ? false }:
        let
          modules = [ self.nixosModules."hardware-${hostname}" ]
            ++ map (moduleName: self.nixosModules.${moduleName}) moduleNames
            ++ map (username: self.nixosModules."user-${username}") usernames
            ++ (if useDwarffs then
              [ dwarffs.nixosModules.dwarffs ]
            else
              [ ]
            ) ++ (if useNixosHardware then
              [ nixos-hardware.nixosModules.${model} ]
            else
              [ ]) ++ [{
                networking.hostName = hostname;
                nixpkgs.hostPlatform = system;
              }];
        in nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = getSpecialArgs {
            inherit model smol system;
            name = hostname;
          };
        }) machines;
      homeConfigurations = joinAttrs (builtins.attrValues (builtins.mapAttrs
        (username:
          { moduleNames, machineNames ? builtins.attrNames machines
          , useXhmm ? false }:
          joinAttrs (map (machineName:
            let
              userPresent =
                builtins.elem username machines.${machineName}.usernames;
              modules = [ self.homeManagerModules."home-${username}" ]
                ++ map (module: self.homeManagerModules.${module}) moduleNames
                ++ (if useXhmm then [ xhmm.homeManagerModules.all ] else [ ]);
            in {
              ${guard userPresent "${username}@${machineName}"} =
                home-manager.lib.homeManagerConfiguration {
                  inherit modules;
                  pkgs =
                    import nixpkgs { system = machines.${machineName}.system; };
                  extraSpecialArgs = getSpecialArgs {
                    inherit (machines.${machineName}) system;
                    model = machines.${machineName}.model or null;
                    smol = machines.${machineName}.smol or false;
                    name = machineName;
                  };
                };
            }) machineNames)) users));
      machines.buggeryyacht = {
        model = "lenovo-legion-y530-15ich";
        system = "x86_64-linux";
        usernames = [ "anselmschueler" ];
        useNixosHardware = true;
        useDwarffs = true;
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
