{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      xhmm,
      nixos-hardware,
      dwarffs,
      disko,
      lanzaboote,
      stylix,
      ...
    }:
    let
      joinAttrs = builtins.foldl' (s1: s2: s1 // s2) { };
      guard = cond: name: if cond then name else null;
      overlays = [ ];
      defaults = {
        model = null;
        gui = true;
        weak = false;
        useNixosHardware = false;
        useDisko = false;
        useDwarffs = false;
        trusted = false;
        vm = false;
        useLanzaboote = false;
        useXhmm = false;
        useStylix = false;
      };
      getSpecialArgs =
        {
          system,
          model ? defaults.model,
          gui ? defaults.gui,
          weak ? defaults.weak,
          name,
          useDwarffs ? defaults.useDwarffs,
          trusted ? defaults.trusted,
          useNixosHardware ? defaults.useNixosHardware,
          vm ? defaults.vm,
          useDisko ? defaults.useDisko,
          useLanzaboote ? defaults.useLanzaboote,
          useStylix ? defaults.useStylix,
          ...
        }:
        {
          machine-model = model;
          machine-name = name;
          machine-gui = gui;
          machine-weak = weak;
          machine-vm = vm;
          source-flake = self;
          configuration-trusted = trusted;
          configuration-dwarffs = useDwarffs;
          configuration-nixos-hardware = useNixosHardware;
          configuration-disko = useDisko;
          configuration-lanzaboote = useLanzaboote;
          configuration-stylix = useStylix;
          inherit system;
        }
        // joinAttrs (
          map (inputName: { "input-${inputName}" = inputs.${inputName}; }) (builtins.attrNames inputs)
        )
        // joinAttrs (
          map
            (nixpkgsVersionName: {
              "${nixpkgsVersionName}" = import inputs.${nixpkgsVersionName} { inherit system; };
            })
            [
              "nixpkgs"
              "nixpkgs-vscode-lldb"
            ]
        );
      nixosConfigurations = builtins.mapAttrs (
        hostname:
        {
          system,
          usernames ? [ ],
          model ? defaults.model,
          moduleNames ? [ "default" ],
          useNixosHardware ? defaults.useNixosHardware,
          useDisko ? defaults.useDisko,
          useDwarffs ? defaults.useDwarffs,
          weak ? defaults.weak,
          gui ? defaults.gui,
          trusted ? defaults.trusted,
          vm ? defaults.vm,
          useLanzaboote ? defaults.useLanzaboote,
          useStylix ? defaults.useStylix,
          styleModule ? null,
          stateVersion,
        }:
        let
          modules =
            [ self.nixosModules."hardware-${hostname}" ]
            ++ map (moduleName: self.nixosModules.${moduleName}) moduleNames
            ++ map (username: self.nixosModules."user-${username}") usernames
            ++ (if useDwarffs then [ dwarffs.nixosModules.dwarffs ] else [ ])
            ++ (if useNixosHardware then [ nixos-hardware.nixosModules.${model} ] else [ ])
            ++ (if useDisko then [ disko.nixosModules.default ] else [ ])
            ++ (if useLanzaboote then [ lanzaboote.nixosModules.lanzaboote ] else [ ])
            ++ (
              if useStylix then
                [
                  stylix.nixosModules.stylix
                  styleModule
                ]
              else
                [ ]
            )
            ++ [
              {
                networking.hostName = hostname;
                nixpkgs.hostPlatform = system;
              }
            ]
            ++ [
              { nixpkgs.overlays = overlays; }
              { system.stateVersion = stateVersion; }
            ];
        in
        nixpkgs.lib.nixosSystem {
          inherit system modules;
          specialArgs = getSpecialArgs {
            inherit
              model
              weak
              system
              gui
              stateVersion
              useNixosHardware
              useDisko
              useDwarffs
              trusted
              vm
              useLanzaboote
              ;
            name = hostname;
          };
        }
      ) machines;
      homeConfigurations = joinAttrs (
        builtins.attrValues (
          builtins.mapAttrs (
            username:
            {
              machineNames ? builtins.attrNames machines,
              user,
              stateVersions ? { },
            }:
            joinAttrs (
              map (
                machineName:
                let
                  user' = if builtins.isFunction user then user (machine // { name = machineName; }) else user;
                  userPresent = builtins.elem username machines.${machineName}.usernames;
                  machine = machines.${machineName};
                  modules =
                    [ self.homeManagerModules."home-${username}" ]
                    ++ map (module: self.homeManagerModules.${module}) user'.moduleNames
                    ++ (if user'.useXhmm or defaults.useXhmm then [ xhmm.homeManagerModules.all ] else [ ])
                    ++ (
                      if user'.useStylix or defaults.useStylix && (!user' ? styleModule -> machine.useStylix) then
                        [
                          stylix.homeManagerModules.stylix
                          user'.styleModule or machine.styleModule
                        ]
                      else
                        [ ]
                    )
                    ++ [
                      { nixpkgs.overlays = overlays; }
                      { home.stateVersion = stateVersions.${machineName} or machines.${machineName}.stateVersion; }
                    ];
                in
                {
                  ${guard userPresent "${username}@${machineName}"} = home-manager.lib.homeManagerConfiguration {
                    inherit modules;
                    extraSpecialArgs = getSpecialArgs (machines.${machineName} // { name = machineName; });
                    pkgs = import nixpkgs { system = machines.${machineName}.system; };
                  };
                }
              ) machineNames
            )
          ) users
        )
      );
      machines.nailbox = {
        model = "framework-16-7040-amd";
        system = "x86_64-linux";
        usernames = [ "anselmschueler" ];
        useNixosHardware = true;
        useDisko = true;
        stateVersion = "23.11";
        trusted = true;
        useLanzaboote = true;
        useStylix = true;
        # useDwarffs = true;
        styleModule = ./stylixModules/style-1.nix;
      };
      users.anselmschueler = {
        user =
          {
            gui ? defaults.gui,
            weak ? defaults.weak,
            ...
          }:
          {
            moduleNames =
              [
                "git"
                "shell"
              ]
              ++ nixpkgs.lib.optionals gui [
                "desktop"
                "vscode-cpp"
                "vscode-haskell"
                "vscode-java"
                "vscode-nix"
                "vscode-python"
                "vscode-rust"
                "vscode"
              ]
              ++ nixpkgs.lib.optionals (!weak) [ "coding" ];
            useXhmm = true;
            useStylix = true;
            styleModule = ./stylixModules/style-1.nix;
          };
        stateVersions.nailbox = "23.11";
      };
    in
    {
      inherit nixosConfigurations;
      inherit homeConfigurations;
      nixosModules = {
        default = import ./nixosModules/configuration.nix;
        user-anselmschueler = import ./nixosModules/users/anselmschueler.nix;
        hardware-buggeryyacht = import ./nixosModules/hardware/buggeryyacht.nix;
        hardware-vm-hulahoop = import ./nixosModules/hardware/vm-hulahoop.nix;
        hardware-nailbox = import ./nixosModules/hardware/nailbox.nix;
      };
      homeManagerModules = joinAttrs (
        map (path: {
          ${builtins.head (builtins.match "(.*).nix" path)} = import (./homeManagerModules + "/${path}");
        }) (builtins.attrNames (builtins.readDir ./homeManagerModules))
      );
    };
}
