{
  inputs = { nixos.url = "github:NixOS/nixpkgs/nixos-unstable"; };
  outputs = { self, nixos }: {
    nixosConfigurations.buggeryyacht-nixos = nixos.lib.nixosSystem {
      system = "x86_64-linux";
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
