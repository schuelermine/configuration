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
  outputs =
    inputs@{ self, nixpkgs, home-manager, xhmm, nixos-hardware, dwarffs, ... }:
    let
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      guard = cond: name: if cond then name else null;
      overlays = [ ];
      defaults = {
        model = null;
        hidpi = false;
        gui = true;
        weak = false;
        useNixosHardware = false;
        useDwarffs = false;
      };
      getSpecialArgs = { system, model ? defaults.model, hidpi ? defaults.hidpi
        , gui ? defaults.gui, weak ? defaults.weak, name
        , useDwarffs ? defaults.useDwarffs
        , useNixosHardware ? defaults.useNixosHardware, ... }:
        {
          machine-model = model;
          machine-name = name;
          machine-hidpi = hidpi;
          machine-gui = gui;
          machine-weak = weak;
          source-flake = self;
          configuration-dwarffs = useDwarffs;
          configuration-nixos-hardware = useNixosHardware;
          inherit system;
        } // joinAttrs
        (map (inputName: { "input-${inputName}" = inputs.${inputName}; })
          (builtins.attrNames inputs)) // joinAttrs (map (nixpkgsVersionName: {
            "${nixpkgsVersionName}" =
              import inputs.${nixpkgsVersionName} { inherit system; };
          }) [ "nixpkgs" "nixpkgs-vscode-lldb" ]);
      nixosConfigurations = builtins.mapAttrs (hostname:
        { system, usernames ? [ ], model ? defaults.model
        , moduleNames ? [ "default" ]
        , useNixosHardware ? defaults.useNixosHardware
        , useDwarffs ? defaults.useDwarffs, weak ? defaults.weak
        , hidpi ? defaults.hidpi, gui ? defaults.gui, stateVersion }:
        let
          modules = [ self.nixosModules."hardware-${hostname}" ]
            ++ map (moduleName: self.nixosModules.${moduleName}) moduleNames
            ++ map (username: self.nixosModules."user-${username}") usernames
            ++ (if useDwarffs then [ dwarffs.nixosModules.dwarffs ] else [ ])
            ++ (if useNixosHardware then
              [ nixos-hardware.nixosModules.${model} ]
            else
              [ ]) ++ [{
                networking.hostName = hostname;
                nixpkgs.hostPlatform = system;
              }] ++ [
                { nixpkgs.overlays = overlays; }
                { system.stateVersion = stateVersion; }
              ];
        in nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = getSpecialArgs {
            inherit model weak system hidpi;
            name = hostname;
          };
        }) machines;
      homeConfigurations = joinAttrs (builtins.attrValues (builtins.mapAttrs
        (username:
          { machineNames ? builtins.attrNames machines, user
          , stateVersions ? { } }:
          joinAttrs (map (machineName:
            let
              user' = if builtins.isFunction user then
                user (machines.${machineName} // { name = machineName; })
              else
                user;
              userPresent =
                builtins.elem username machines.${machineName}.usernames;
              modules = [ self.homeManagerModules."home-${username}" ]
                ++ map (module: self.homeManagerModules.${module})
                user'.moduleNames ++ (if user'.useXhmm then
                  [ xhmm.homeManagerModules.all ]
                else
                  [ ]) ++ [
                    { nixpkgs.overlays = overlays; }
                    {
                      home.stateVersion =
                        stateVersions.${machineName} or machines.${machineName}.stateVersion;
                    }
                  ];
            in {
              ${guard userPresent "${username}@${machineName}"} =
                home-manager.lib.homeManagerConfiguration {
                  inherit modules;
                  extraSpecialArgs = getSpecialArgs
                    (machines.${machineName} // { name = machineName; });
                  pkgs =
                    import nixpkgs { system = machines.${machineName}.system; };
                };
            }) machineNames)) users));
      machines.buggeryyacht = {
        model = "lenovo-legion-y530-15ich";
        system = "x86_64-linux";
        usernames = [ "anselmschueler" ];
        hidpi = true;
        useNixosHardware = true;
        useDwarffs = true;
        stateVersion = "22.11";
      };
      users.anselmschueler = {
        user = { gui ? defaults.gui, weak ? defaults.weak, ... }: {
          moduleNames = [ "git" "shell" ] ++ nixpkgs.lib.optionals gui [
            "desktop"
            "vscode-cpp"
            "vscode-haskell"
            "vscode-java"
            "vscode-nix"
            "vscode-python"
            "vscode-rust"
            "vscode"
          ] ++ nixpkgs.lib.optionals (!weak) [ "coding" ];
          useXhmm = true;
        };
        stateVersions.buggeryyacht = "21.11";
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
