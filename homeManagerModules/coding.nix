{ pkgs, input-fenix, ... }: {
  programs = {
    haskell = {
      ghc = {
        enable = true;
        ghciConfig = ''
          :set +m
          :set +t
          :set +s
        '';
      };
      cabal.enable = true;
      stack.enable = true;
    };
    rust.customToolchain.toolchainPackage =
      input-fenix.packages.${pkgs.system}.complete.toolchain;
    python = {
      versionName = "3.10";
      enable = true;
      mypy = { enable = true; };
    };
  };
  home.packages = with pkgs; [ openjdk clang gdb ];
}
