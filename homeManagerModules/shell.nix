{ pkgs, input-nixos-repl-setup, ... }: {
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
        ll = "exa -lFs type";
        lg = "exa -lFGs type";
        la = "exa -aFs type";
        l- = "exa -alFs type";
        "l." = "exa -alFGs type";
        tree = "exa --tree";
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
      in repl-setup { source = "git+file:///home/anselmschueler/Documents/git/github.com/schuelermine/configuration"; isUrl = true; } // builtins
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
