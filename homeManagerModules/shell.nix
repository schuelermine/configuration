{ pkgs, input-nixos-repl-setup, machine-name, source-flake, ... }: {
  services.gpg-agent = {
    pinentryFlavor = "gnome3";
    enable = true;
  };
  programs = {
    gpg.enable = true;
    less = {
      enable = true;
      options = [ "-Rm" "--use-color" ];
    };
    nano = {
      enable = true;
      config = ''
        set smarthome
        set boldtext
        set tabstospaces
        set historylog
        set positionlog
        set softwrap
        set zap
        set atblanks
        set autoindent
        set linenumbers
        set cutfromcursor
        set mouse
        set indicator
        set afterends
        set stateflags
        set tabsize 4
      '';
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    exa.enable = true;
    direnv.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        ls = "exa -s type";
        ll = "exa -lhFs type --git";
        lg = "exa -lhFGs type --git";
        la = "exa -aFs type";
        l- = "exa -alhFs type --git";
        "l." = "exa -alhFGs type --git";
        lt = "exa --tree";
        le = "exa -lh --tree --git";
        l1 = "exa -1s type";
        cd = "z";
        c = "bat";
      };
      prompt = builtins.readFile ../source/prompt.fish;
      shellInit = builtins.concatStringsSep "\n" (map builtins.readFile [
        ../source/colors.fish
        ../source/features.fish
        ../source/commands.fish
      ]);
    };
  };
  home = {
    file."repl.nix".text = ''
      let repl-setup = import ${input-nixos-repl-setup};
      in repl-setup {
        source = "${source-flake}";
        hostname = "${machine-name}";
        isUrl = true;
        passExtra = [
          [ "lib" [ "inputs" "nixpkgs" "lib" ] ]
          [ "outputs" "homeConfigurations" ]
          [ "outputs" "homeManagerModules" ]
          [ "outputs" "nixosModules" ]
          [ "outputs" "nixosConfigurations" ]
        ];
      } // builtins
    '';
    packages = with pkgs; [
      haskellPackages.ret
      asciinema
      chafa
      powershell
      nushell
    ];
  };
}
