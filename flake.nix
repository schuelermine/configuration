{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-lib.url = "github:schuelermine/nix-lib/b0";
    nix-symlink.url = "github:schuelermine/nix-symlink/b0";
  };
  outputs = { self, nixpkgs, nix-symlink, nix-lib }:
    with nix-lib; {
      nixosConfigurations.buggeryyacht-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit (nix-symlink) symlink; };
        modules = attrs.mapToValues (n: _: ./modules + "/${n}")
          (attrs.filter (n: t: t == "regular") (builtins.readDir ./config));
      };
    };
}
