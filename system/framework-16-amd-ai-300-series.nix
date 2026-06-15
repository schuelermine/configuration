{ config, lib, pkgs, ... }:
# taken from https://github.com/NixOS/nixos-hardware
{
  services.fwupd.enable = true;
  boot.kernelParams = [
    # See https://gist.github.com/lbrame/f9034b1a9fe4fc2d2835c5542acb170a#user-content-quick-version-apply-the-mitigations-i-am-personally-using
    # "amdgpu.dcdebugmask=0x410"
    # "amdgpu.sg_display=0"
    # "amdgpu.abmlevel=0"
    # power mgmt
    "amd_pstate=active"
  ];
  services.fprintd.enable = lib.mkDefault true;
  services.udev.extraRules = ''
    # Ethernet expansion card support
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", ATTR{power/autosuspend}="20"
    # Allow access to the keyboard modules for programming, for example by
    # visiting https://keyboard.frame.work with a WebHID-compatible browser.
    #
    # https://community.frame.work/t/responded-help-configuring-fw16-keyboard-with-via/47176/5
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
  hardware.sensor.iio.enable = lib.mkDefault true;
  hardware.keyboard.qmk.enable = lib.mkDefault true;
  services.tlp.enable = lib.mkDefault (!config.services.power-profiles-daemon.enable); #?
  services.fstrim.enable = lib.mkDefault true;
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [
      framework-laptop-kmod
    ];
    # https://github.com/DHowett/framework-laptop-kmod?tab=readme-ov-file#usage
    kernelModules = [
      "cros_ec"
      "cros_ec_lpcs"
    ];
  };
  environment.systemPackages = [ pkgs.framework-tool ];
  # https://community.frame.work/t/responded-amd-7040-sleep-states/38101/13
  services.power-profiles-daemon.enable = lib.mkDefault true;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  services.xserver.videoDrivers = lib.mkDefault [ "modesetting" ];
  hardware.graphics = {
    enable = lib.mkDefault true;
    enable32Bit = lib.mkDefault true;
  };
  hardware.amdgpu.initrd.enable = lib.mkDefault true;
}
