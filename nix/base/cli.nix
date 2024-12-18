{ config, pkgs, ... }:

{
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # self-explaining one-liners
  console.keyMap = "de";
  time.timeZone = "Europe/Berlin";
  nixpkgs.config.allowUnfree = true;

  # nix experimental features
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
        experimental-features = nix-command flakes
    '';
  };

  # locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = false;
      allowedTCPPorts = [];
      allowedUDPPorts = [];
    };
  };
  # Enables wireless support via wpa_supplicant.
  # networking.wireless.enable = true;

  # user and group config
  users.groups.niklas = {};
  users.users.niklas = {
    isNormalUser = true;
    description = "Niklas";
    initialPassword = "1qay!QAY";
    extraGroups = [ "niklas" "networkmanager" "wheel" ];
  };

  #################################
  ########### LIBRARIES ###########
  #################################
  programs.nix-ld.dev.enable = true;
  programs.nix-ld.dev.libraries = with pkgs; [
    # Add here any missing dynamic libraries for unpackaged programs
  ];

  #################################
  ############ PACKAGES ###########
  #################################

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # general
    git
    bash
    zip
    vim
    nano
    wget
    curl
    bind
    traceroute
    speedtest-cli
    htop
    jq  # format json
    usbutils
    xsensors
    static-web-server # http server
  ];
  
  #################################
  ###### PROGRAMS / SERVICES ######
  #################################
  
  services.gnome.gnome-keyring.enable = true;
  
  programs.ssh = {
    startAgent = true;
    hostKeyAlgorithms      = [ "ssh-ed25519" "ssh-rsa" ];
    pubkeyAcceptedKeyTypes = [ "ssh-ed25519" "ssh-rsa" ];
  };

  virtualisation.docker = {
    enable = true;
    # better security than adding user to "docker" group
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  programs.direnv.enable = true;

  #################################
  ######### SHELL ALIASES #########
  #################################
  environment.shellAliases = {
    rebuild = "sudo nixos-rebuild switch --flake /etc/dotfiles/nix#$NIX_FLAKE_DEFAULT_HOST";
    update = "nix flake update /etc/dotfiles/nix";
    serve = "static-web-server --port 3000 --root ./";
    encrypt-as-zip = "function _ezip() { zip --encrypt \"\${1}.zip\" \"\$1\"; }; _ezip";
  };

  #################################
  ########## HOME-MANAGER #########
  #################################
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.niklas = {
    # basic home-manager config
    home.username = "niklas";
    home.homeDirectory = "/home/niklas";
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;


  };
}
