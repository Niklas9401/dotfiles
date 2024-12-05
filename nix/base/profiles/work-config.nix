{ config, pkgs, lib, nix-vscode-extensions, ... }:

{
  nixpkgs.config.allowUnsupportedSystem = true;

  #################################
  ############ PACKAGES ###########
  #################################

  services.tailscale.enable = true;


  environment.variables = {
    CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  # List GUI packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libreoffice-qt6-fresh
    tailscale
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdotool

    # AWS stuff
    # awscli2

    # Javascript stuff
    # nodejs_20  # switch to v22 in October 2024 (because it is currently not LTS)
    # yarn
    spotify
    teams-for-linux
    flutter
  ];

  #################################
  ###### PROGRAMS / SERVICES ######
  #################################
  # services.pcscd.enable = true;

  #################################
  ######### SHELL ALIASES #########
  #################################
  # no additional config (see nix/base/general_profile.nix)

  #################################
  ########## HOME-MANAGER #########
  #################################

  home-manager.users.niklas = {

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [];
        enabled-extensions = [
          pkgs.gnomeExtensions.dash-to-dock.extensionUuid
          pkgs.gnomeExtensions.user-themes.extensionUuid
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.media-controls.extensionUuid
          # pkgs.gnomeExtensions.pano.extensionUuid
          # pkgs.gnomeExtensions.quick-settings-tweaker.extensionUuid
          # pkgs.gnomeExtensions.just-perfection.extensionUuid

        ];
      };
      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "google-chrome.desktop"
          "code.desktop"
          "idea-ultimate.desktop"
          "android-studio.desktop"
          "sublime_merge.desktop"
          "org.gnome.Console.desktop"
        ];
      };
    };

   programs.git = {
      userName = "Niklas Weiblen";
      userEmail = "niklas.weiblen@focke.de";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "/home/niklas/.ssh/id_ed25519.pub";
      };
    };
  };  
}
    # home.file.".ssh/config".text = ''
    #   Host ssh.dev.azure.com
    #     User git
    #     PubkeyAcceptedAlgorithms +ssh-rsa
    #     HostkeyAlgorithms +ssh-rsa
      
    #   Host vs-ssh.visualstudio.com
    #     User git
    #     PubkeyAcceptedAlgorithms +ssh-rsa
    #     HostkeyAlgorithms +ssh-rsa
    # '';