{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../base/general_profile.nix
    ../../base/profiles/personal-config.nix
  ];
    
  # Bootloader
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot.enable = false;
    grub = {
      enable = true;
      enableCryptodisk = true;
      useOSProber = true;
      device = "nodev";
      efiSupport = true;
    };
  };

  # Swapfile
  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024; # 8 GiB
  }];

  # Network
  networking.hostName = "niklas-laptop"; # Define your hostname.
}
