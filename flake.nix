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
  };
  outputs = inputs@{ self, nixpkgs, home-manager, xhmm, nixos-hardware, ... }:
    let
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      guard = cond: name: if cond then name else null;
      getSpecialArgs = { modules, model, powerful }:
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
              machine-powerful = powerful;
              machine-model = model;
            };
      nixosConfigurations = builtins.mapAttrs (hostname:
        { system, usernames ? [ ], model ? null, moduleNames ? [ "default" ]
        , useNixosHardware ? false, powerful ? false }:
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
          specialArgs = getSpecialArgs { inherit modules model powerful; };
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
                    inherit modules;
                    model = machines.${machineName}.model or null;
                    powerful = machines.${machineName}.powerful or false;
                  };
                };
            }) machineNames)) users));
      machines.buggeryyacht = {
        model = "lenovo-legion-y530-15ich";
        system = "x86_64-linux";
        usernames = [ "anselmschueler" ];
        useNixosHardware = true;
        powerful = true;
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
