{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-fix-noto-cjk-src.url = "github:midchildan/nixpkgs/fix/noto-cjk-src";
    nix-lib.url = "github:schuelermine/nix-lib/b0";
    nix-symlink.url = "github:schuelermine/nix-symlink/b0";
  };
  outputs = { self, nixpkgs, nix-symlink, nixpkgs-fix-noto-cjk-src, nix-lib }:
    with nix-lib; {
      nixosConfigurations.buggeryyacht-nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          nixpkgs-fix-noto-cjk-src = import nixpkgs-fix-noto-cjk-src { };
          symlink = nix-symlink.symlink;
        };
        modules = attrs.mapToValues (n: _: ./modules + "/${n}")
          (attrs.filter (n: t: t == "regular") (builtins.readDir ./modules));
      };
    };
}
