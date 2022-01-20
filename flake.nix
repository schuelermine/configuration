{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-lib.url = "github:schuelermine/nix-lib/b0";
    nix-symlink.url = "github:schuelermine/nix-symlink/b0";
  };
  outputs = { self, nixpkgs, nix-symlink, nix-lib }: {
    nixosConfigurations.buggeryyacht-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.symlink = nix-symlink.symlink;
      modules = nix-lib.mapToValuesX
        (name: type: if type != "regular" then [ ] else [ (./. + name) ])
        (builtins.readDir ./modules);
    };
  };
}
