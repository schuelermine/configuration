{ pkgs, lib, input-nixos-repl-setup, machine-name, machine-gui, source-flake
, ... }: {
  home.sessionVariables.EXA_COLORS = "xx=2";
  services.gpg-agent = {
    pinentryFlavor = lib.mkIf machine-gui "gnome3";
    enable = true;
  };
  programs = {
    bat = {
      enable = true;
      config.style = "numbers,changes,rule,snip";
    };
    gpg.enable = true;
    less = {
      enable = true;
      options = [ "-SRm" "--use-color" ];
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
        ll = "eza -lhF -s type --git";
        lg = "eza -lhFG -s type --git";
        la = "eza -aF -s type";
        l- = "eza -alhF -s type --git";
        "l." = "eza -alhFG -s type --git";
        lt = "eza -s type --tree";
        le = "eza -lh -s type --tree --git";
        l1 = "eza -1 -s type";
        y = "z";
        c = "bat";
      };
      prompt = builtins.readFile ../source/prompt.fish;
      interactiveShellInit = builtins.concatStringsSep "\n"
        (map builtins.readFile [
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
    packages = with pkgs; [ haskellPackages.ret asciinema powershell nushell ];
  };
}
