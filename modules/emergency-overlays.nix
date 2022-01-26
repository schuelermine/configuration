{ pkgs, nixpkgs-future }: {
  nixpkgs.overlays = [
    # This is to preemptively apply nixpkgs PR #156342 to fix Noto CJK downloads
    (self: super: {
      inherit (nixpkgs-future) noto-fonts-cjk-sans noto-fonts-cjk-serif;
    })
  ];
}
