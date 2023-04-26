{ config, pkgs, input-fenix, input-nix-vscode-extensions, ... }: {
  programs = {
    vscode = {
      extensions = with input-nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [ rust-lang.rust-analyzer ];
      userSettings = {
        "[rust]"."editor.formatOnSave" = true;
        "rust-analyzer.server.path" =
          "${config.programs.rust.rust-analyzer.package}/bin/rust-analyzer";
      };
    };
    rust.exposeRustSrcLocation = "${input-fenix.packages.${pkgs.system}.latest.rust-src}";
  };
}
