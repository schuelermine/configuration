{ pkgs, ... }: {
  nixpkgs.overlays = [
    # This is to preemptively apply nixpkgs PR #156342 to fix Noto CJK downloads
    (self: super:
      let
        mkNotoCJK = { typeface, version, rev, sha256 }:
          super.stdenvNoCC.mkDerivation {
            pname = "noto-fonts-cjk-${super.lib.toLower typeface}";
            inherit version;
            src = super.fetchFromGitHub {
              owner = "googlefonts";
              repo = "noto-cjk";
              sparseCheckout = "${typeface}/OTC";
              inherit rev sha256;
            };
            installPhase = ''
              install -m444 -Dt $out/share/fonts/opentype/noto-cjk ${typeface}/OTC/*.ttc
            '';
            meta = {
              description = "Beautiful and free fonts for CJK languages";
              homepage = "https://www.google.com/get/noto/help/cjk/";
              longDescription = ''
                Noto ${typeface} CJK is a ${
                  super.lib.toLower typeface
                } typeface designed as
                an intermediate style between the modern and traditional. It is
                intended to be a multi-purpose digital font for user interface
                designs, digital content, reading on laptops, mobile devices, and
                electronic books. Noto ${typeface} CJK comprehensively covers
                Simplified Chinese, Traditional Chinese, Japanese, and Korean in a
                unified font family. It supports regional variants of ideographic
                characters for each of the four languages. In addition, it supports
                Japanese kana, vertical forms, and variant characters (itaiji); it
                supports Korean hangeul — both contemporary and archaic.
              '';
              license = super.noto-fonts-cjk-sans.meta.license;
              platforms = super.noto-fonts-cjk-sans.meta.platforms;
              maintainers = super.noto-fonts-cjk-sans.meta.maintainers;
            };
          };
      in {
        noto-fonts-cjk-sans = mkNotoCJK {
          typeface = "Sans";
          version = "2.004";
          rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
          sha256 = "sha256-pNC/WJCYHSlU28E/CSFsrEMbyCe/6tjevDlOvDK9RwU=";
        };
        noto-fonts-cjk-serif = mkNotoCJK {
          typeface = "Serif";
          version = "2.000";
          rev = "9f7f3c38eab63e1d1fddd8d50937fe4f1eacdb1d";
          sha256 = "sha256-Iy4lmWj5l+/Us/dJJ/Jl4MEojE9mrFnhNQxX2zhVngY=";
        };
      })
  ];
}
