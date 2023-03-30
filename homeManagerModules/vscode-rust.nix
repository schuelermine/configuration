{ config, pkgs, input-fenix, ... }: {
  programs = {
    vscode = {
      extensions = (with pkgs.vscode-extensions; [ rust-lang.rust-analyzer ])
        ++ [ (pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "rustdoc-theme";
            publisher = "arzg";
            version = "1.0.0";
            sha256 = "sha256-EaKicSFemk5G9ICToYhZAUMEMqsoMEXwGfczYZ68STI=";
          };
        }) ];
      userSettings = {
        "workbench.colorTheme" = "rustdoc dark";
        "[rust]"."editor.formatOnSave" = true;
        "rust-analyzer.server.path" =
          "${config.programs.rust.rust-analyzer.package}/bin/rust-analyzer";
      };
    };
    rust.exposeRustSrcLocation =
      "${input-fenix.packages.${pkgs.system}.latest.rust-src}";
  };
}
