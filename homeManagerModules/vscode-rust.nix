{ config, pkgs, input-fenix, ... }: {
  programs = {
    vscode = {
      extensions = with pkgs.vscode-extensions; [ rust-lang.rust-analyzer ];
      userSettings = {
        "[rust]"."editor.formatOnType" = true;
        "rust-analyzer.server.path" =
          "${config.programs.rust.rust-analyzer.package}/bin/rust-analyzer";
      };
    };
    rust.exposeRustSrcLocation = "${input-fenix.packages.${pkgs.system}.latest.rust-src}";
  };
}
