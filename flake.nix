{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-lib.url = "github:schuelermine/nix-lib/b0";
  };
  outputs = { self, nixpkgs, nix-lib }: {
      nixosConfigurations.buggeryyacht = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs; };
        modules = with nix-lib.lib; mapAttrsToValues (n: _: ./config + "/${n}")
          (filterAttrs (n: t: t == "regular") (builtins.readDir ./config));
      };
    };
}
