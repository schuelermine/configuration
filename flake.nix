{
  inputs = {
    nixos.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-symlink.url = "github:schuelermine/nix-symlink/b0";
  };
  outputs = { self, nixos, nix-symlink }: {
    nixosConfigurations.buggeryyacht-nixos = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.symlink = nix-symlink.symlink;
      modules = [
        ./modules/boot.nix
        ./modules/console.nix
        ./modules/desktop.nix
        ./modules/hardware.nix
        ./modules/nvidia.nix
        ./modules/system.nix
        ./modules/users.nix
        { nixpkgs.overlays = [ self.overlay ]; }
      ];
    };
    overlay = import ./overlay.nix;
  };
}
