{ config, pkgs, pkgs-unstable, nix-vscode-extensions, ... }:

{
  # imports = [
  #   ../modules/airplay-server.nix
  # ];

  #################################
  ############ PACKAGES ###########
  #################################

  # List GUI packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # general
    steam
    vesktop
    ausweisapp
    whatsapp-for-linux

    # other coding stuff
    rpi-imager

    # 3d printing
    # openscad
    # prusa-slicer

    # other
    yubioath-flutter
    thefuck

    (vscode-with-extensions.override {
      # TODO remove after unstable updated to 1.93.0
      vscode = pkgs.vscode.overrideAttrs(old: rec {
        version = "1.94.2";
        plat = "linux-x64";
        src = fetchurl {
          name = "VSCode_${version}_${plat}.tar.gz";
          url = "https://update.code.visualstudio.com/${version}/${plat}/stable";
          sha256 = "NktZowxWnt96Xa4Yxyv+oMmwHGylYIxFrpws/y0XhXA=";
        };
      });

      vscodeExtensions = let
        vscode-extensions = nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system};
      in
        with pkgs.lib.foldl' (acc: set: pkgs.lib.recursiveUpdate acc set) {} [
          vscode-extensions.vscode-marketplace
          # vscode-extensions.open-vsx # TODO use after ms-toolsai.jupyter is updated to v2024.8.x
          vscode-extensions.vscode-marketplace-release
          # vscode-extensions.open-vsx-release # TODO use after ms-toolsai.jupyter is updated to v2024.8.x
        ];
      [
        # general
        axelrindle.duplicate-file
        ms-azuretools.vscode-docker
        github.copilot

        swssr.region-wrapper

        # nix
        bbenoist.nix
        mkhl.direnv

        # remote workspaces
        ms-vscode-remote.remote-containers
        # github.codespaces

        # python
        # ms-toolsai.jupyter
        # ms-python.vscode-pylance
        # ms-python.python
      ];
    })
  ];

  #################################
  ###### PROGRAMS / SERVICES ######
  #################################
  services.pcscd.enable = true; # required for Yubico Authenticator

  networking.firewall = {
    allowedTCPPorts = [];
    allowedUDPPorts = [
      # Matter IoT protocol
      # 5353 # mDNS
      # 5540 # Matter
    ];
  };

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
          "vesktop.desktop"
          "steam.desktop"
          "spotify.desktop"
          "google-chrome.desktop"
          "code.desktop"
          "idea-ultimate.desktop"
          "rider.desktop"
          "datagrip.desktop"
          "android-studio.desktop"
          "sublime_merge.desktop"
          "org.gnome.Console.desktop"
        ];
      };
    };


    programs.git = {
      userName = "Niklas Weiblen";
      userEmail = "niklas@weiblen.dev";
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