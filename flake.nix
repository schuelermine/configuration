{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-lib.url = "github:schuelermine/nix-lib/b0";
  };
  outputs = { self, nixpkgs, nix-lib }:
    with nix-lib; {
      nixosConfigurations.buggeryyacht = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = attrs.mapToValues (n: _: ./config + "/${n}")
          (attrs.filter (n: t: t == "regular") (builtins.readDir ./config));
      };
    };
}
