{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    (git.override { sendEmailSupport = true; })
    pciutils
    htop
    lsof
    killall
    xorg.xwininfo
    xorg.xkill
    xsel
    imagemagick
    ffmpeg
    file
    nix-info
    nix-top
  ];
  console = {
    packages = [ pkgs.terminus_font ];
    font = "ter-v28b";
    useXkbConfig = true;
    earlySetup = true;
  };

}
