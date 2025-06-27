{
  pkgs,
  lib,
  machine-gui,
  ...
}:
{
  services.gpg-agent = {
    pinentry.package = lib.mkIf machine-gui pkgs.pinentry-gnome3;
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
      functions.man = ''
        COLUMNS=(math "min($COLUMNS, 95)") command man $argv
      '';
      shellAbbrs = {
        c = "bat";
        x = "eza --group-directories-first";
      };
      prompt = builtins.readFile ../source/prompt.fish;
      interactiveShellInit = builtins.concatStringsSep "\n" (
        map builtins.readFile [
          ../source/colors.fish
          ../source/features.fish
          ../source/commands.fish
          ../source/abbr.fish
        ]
      );
    };
  };
  home = {
    packages = with pkgs; [
      haskellPackages.ret
      asciinema
      powershell
      nushell
      typst
      hatch
      uv
      devpod
    ];
    sessionVariables.EXA_COLORS = "xx=2";
  };
  xdg.configFile."uv/uv.toml".text = ''
    python-preference = "only-system"
  '';
}
