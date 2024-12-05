{ config, pkgs, lib, nix-vscode-extensions, ... }:

{
  nixpkgs.config.allowUnsupportedSystem = true;

  #################################
  ############ PACKAGES ###########
  #################################

  programs.chromium.enable = true;
  programs.chromium.extensions = [
    "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
    "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
    "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
  ];

  services.tailscale.enable = true;

  environment.variables = {
    CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  # List GUI packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Jetbrains
    jetbrains.idea-ultimate
    jetbrains.webstorm
    jetbrains.rider
    jetbrains.pycharm-professional
    jetbrains.goland
    jetbrains.datagrip
    android-studio
    libreoffice-qt6-fresh
    tailscale
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdotool

    # AWS stuff
    awscli2

    # Javascript stuff
    # nodejs_20  # switch to v22 in October 2024 (because it is currently not LTS)
    # yarn
    spotify
    teams-for-linux
    google-chrome
    flutter


    # VS Code
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
        k--kato.intellij-idea-keybindings
        axelrindle.duplicate-file
        ms-azuretools.vscode-docker
        github.copilot


        # nix
        bbenoist.nix
        mkhl.direnv

        # remote workspaces
        ms-vscode-remote.remote-containers

        # python
        ms-toolsai.jupyter
        ms-python.vscode-pylance
        ms-python.python
      ];
    })
  ];

  #################################
  ###### PROGRAMS / SERVICES ######
  #################################
  # services.pcscd.enable = true;

  #################################
  ######### SHELL ALIASES #########
  #################################
  # no additional config (see nix/base/gui.nix)

  #################################
  ########## HOME-MANAGER #########
  #################################
  home-manager.users.niklas = {
    home.file.".config/Code/User/settings.json".text = builtins.toJSON {
      "editor.wordWrap" = "on";
      "editor.fontSize" = 14;
      "terminal.integrated.fontSize" = 14;
    };

    home.file.".config/gtk-3.0/bookmarks".text = ''
      file:///etc/dotfiles dotfiles
      file:///home/niklas/Desktop/projects projects
    '';

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

    programs.git = {
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "/home/niklas/.ssh/id_ed25519.pub";
      };
      userEmail = lib.mkForce "niklas.weiblen@focke.de";
    };
  };
}
