{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-symlink.url = "github:schuelermine/nix-symlink/b0";
  };
  outputs = { self, nixpkgs, nix-symlink }: {
    nixosConfigurations.buggeryyacht-nixos = nixpkgs.lib.nixosSystem {
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
      ];
    };
  };
}
