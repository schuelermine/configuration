{ pkgs, ... }:
{
  stylix = {
    cursor = {
      name = "Adwaita";
      size = 24;
    };
    polarity = "dark";
    image = ../blob/adwaita-d.jpg;
    fonts = {
      monospace = {
        package = pkgs.commit-mono;
        name = "CommitMono";
      };
      sansSerif = {
        package = pkgs.fira-sans;
        name = "Fira Sans";
      };
      serif = {
        package = pkgs.libertinus;
        name = "Libertinus Serif";
      };
      sizes.terminal = 14;
    };
  };
}
