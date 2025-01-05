{
  disko.devices.disk.nvme0n1 = {
    device = "/dev/disk/by-id/nvme-WD_BLACK_SN850X_2000GB_23514Y806477";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "10G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=077" ];
          };
        };
        root = {
          name = "root-crypt";
          end = "100%";
          content = {
            type = "luks";
            name = "root";
            settings.allowDiscards = true;
            passwordFile = "/tmp/nixos-install-postsupernova-disko-nvme0n1-luks-password";
            content = {
              type = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
