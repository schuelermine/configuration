{ pkgs, input-nix-vscode-extensions, ... }: {
  programs.vscode = {
    extensions = (with input-nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
      llvm-vs-code-extensions.vscode-clangd
      ms-vscode.cmake-tools
      ms-vscode.makefile-tools
      twxs.cmake
    ]) ++ (with pkgs.vscode-extensions; [
      vadimcn.vscode-lldb
    ]);
    userSettings = {
      "clangd.path" = "${pkgs.clang-tools}/bin/clangd";
      "cmake.cmakePath" = "${pkgs.cmake}/bin/cmake";
      "makefile.makePath" = "${pkgs.gnumake}/bin/make";
    };
  };
}
