{ pkgs, ... }: {
  programs.git = {
    enable = true;
    package = pkgs.gitFull;
  };
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    pciutils
    htop
    lsof
    killall
    imagemagick
    ffmpeg
    file
    man-pages
    trash-cli
    rmtrash
  ];
  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v28b";
    useXkbConfig = true;
    earlySetup = true;
  };
}
