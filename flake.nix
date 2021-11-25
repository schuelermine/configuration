{
  inputs = {
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-21.05";
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixos-stable, nixos-unstable }: {
    nixosConfigurations.buggeryyacht-nixos = let system = "x86_64-linux";
    in nixos-unstable.lib.nixosSystem {
      specialArgs.nixos-stable = import nixos-stable {
        inherit system;
        config.allowUnfree = true;
      };
      inherit system;
      modules = [
        ./modules/boot.nix
        ./modules/console.nix
        ./modules/desktop.nix
        ./modules/hardware.nix
        ./modules/nvidia.nix
        ./modules/system.nix
        ./modules/users.nix
      ];
    };
  };
}
