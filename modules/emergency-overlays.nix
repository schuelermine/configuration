{ pkgs, nixpkgs-fix, ... }: {
  nixpkgs.overlays = [
    # This is to preemptively apply nixpkgs PR #156342 to fix Noto CJK downloads
    (self: super: {
      noto-fonts-cjk-sans = nixpkgs-fix.noto-fonts-cjk-sans;
      noto-fonts-cjk-serif = nixpkgs-fix.noto-fonts-cjk-serif;
    })
  ];
}
