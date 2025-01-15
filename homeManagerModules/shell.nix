{
  pkgs,
  lib,
  machine-gui,
  ...
}:
{
  home.sessionVariables.EXA_COLORS = "xx=2";
  services.gpg-agent = {
    pinentryPackage = lib.mkIf machine-gui pkgs.pinentry-gnome3;
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
      options = [
        "-SRm"
        "--use-color"
      ];
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
      options = [
        "--cmd"
        "y"
      ];
    };
    direnv.enable = true;
    fish = {
      enable = true;
      shellAliases = {
        c = "bat";
        x = "eza";
      };
      prompt = builtins.readFile ../source/prompt.fish;
      interactiveShellInit = builtins.concatStringsSep "\n" (
        map builtins.readFile [
          ../source/colors.fish
          ../source/features.fish
          ../source/commands.fish
        ]
      );
    };
  };
  home.packages = with pkgs; [
    haskellPackages.ret
    asciinema
    powershell
    nushell
    typst
  ];
}
