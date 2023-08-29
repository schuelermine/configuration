{ pkgs, input-nixos-repl-setup, machine-name, source-flake, ... }: {
  home.sessionVariables.EXA_COLORS = "xx=2";
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
    direnv.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        ls = "eza -s type";
        ll = "eza -lhFs type --git";
        lg = "eza -lhFGs type --git";
        la = "eza -aFs type";
        l- = "eza -alhFs type --git";
        "l." = "eza -alhFGs type --git";
        lt = "eza --tree";
        le = "eza -lh --tree --git";
        l1 = "eza -1s type";
        cd = "z";
        c = "bat";
      };
      prompt = builtins.readFile ../source/prompt.fish;
      interactiveShellInit = builtins.concatStringsSep "\n" (map builtins.readFile [
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
          [ "inputs" "nixpkgs" "lib" ]
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
      powershell
      nushell
    ];
  };
}
