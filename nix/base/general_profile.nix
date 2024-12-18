{ config, pkgs, nix-vscode-extensions, ... }:

{
  imports = [
    ./cli.nix
  ];

  #################################
  ############ PACKAGES ###########
  #################################

  programs.chromium = {
    enable = true;
    extraOpts = {
      "PasswordManagerEnabled" = false;
    };
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
  };

  # Android Debug Bridge
  programs.adb.enable = true;
  users.users."niklas".extraGroups = ["adbusers"];

  environment.variables = {
    # Need for flutter
    CHROME_EXECUTABLE = "${pkgs.google-chrome}/bin/google-chrome-stable";
  };

  # List GUI packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    # gnome
    gnome3.dconf-editor
    gnomeExtensions.dash-to-dock
    gnomeExtensions.user-themes
    gnomeExtensions.system-monitor
    gnomeExtensions.coverflow-alt-tab
    gnomeExtensions.just-perfection
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.media-controls
    gnomeExtensions.cronomix
    # gnomeExtensions.quick-settings-tweaker
    # gnomeExtensions.just-perfection
    # gnomeExtensions.pano
    
    # Jetbrains
    jetbrains.idea-ultimate
    jetbrains.webstorm
    jetbrains.rider
    jetbrains.pycharm-professional
    jetbrains.goland
    jetbrains.datagrip
    android-studio

    # Flameshot requirements
    xdg-desktop-portal
    xdg-desktop-portal-gnome
    xdotool
    flameshot

    # general
    spotify
    google-chrome
    firefox
    vlc
    pinta
    pdfarranger
    drawio
    vscode
    libreoffice-qt6-fresh

    #Open Broadcaster Studio
    obs-studio
    obs-studio-plugins.wlrobs
    
    # technical
    sublime-merge
    wireshark
    gparted
    insomnia
    myxer

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    # media-session.enable = true;
  };

  hardware.pulseaudio.enable = false;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Microhpone noise suppression
  programs.noisetorch.enable = true;

  #################################
  ######### SHELL ALIASES #########
  #################################
  environment.shellAliases = {
    cdconfig = "cd /etc/dotfiles";
    cddownloads = "cd ~/Downloads";
    cdprojects = "cd ~/Desktop/projects";
    cls = "echo 'Are you stupid? I hate Windows and CMD!'";
  };

  environment.gnome.excludePackages = with pkgs.gnome; [
      gnome-screenshot
  ];

  #################################
  ########## HOME-MANAGER #########
  #################################
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
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

    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [];
        enabled-extensions = [
          pkgs.gnomeExtensions.dash-to-dock.extensionUuid
          pkgs.gnomeExtensions.user-themes.extensionUuid
          pkgs.gnomeExtensions.system-monitor.extensionUuid
          pkgs.gnomeExtensions.media-controls.extensionUuid
          pkgs.gnomeExtensions.coverflow-alt-tab.extensionUuid
          pkgs.gnomeExtensions.just-perfection.extensionUuid
          pkgs.gnomeExtensions.tray-icons-reloaded.extensionUuid  
          pkgs.gnomeExtensions.cronomix.extensionUuid
          # pkgs.gnomeExtensions.pano.extensionUuid
          # pkgs.gnomeExtensions.quick-settings-tweaker.extensionUuid
          # pkgs.gnomeExtensions.just-perfection.extensionUuid

        ];
      };
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        show-battery-percentage = true;
        color-scheme = "prefer-dark";
        # gtk-theme = "Yaru";
        # cursor-theme = "Yaru";
        # icon-theme = "Yaru";
      };
      "org/gnome/shell/extensions/user-theme" = {
        # name = "Yaru-dark";
      };
      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "BOTTOM";
        dock-fixed = true;
        extend-height = true;
        dash-max-icon-size = 32;
        click-action = "minimize-or-previews";
        multi-monitor = true;
        scroll-action = "cycle-windows";
        disable-overview-on-startup = true;
        running-indicator-style = "DOTS";
      };
      "org/gnome/shell" = {
        favorite-apps = [
          # "chrome-cifhbcnohmdccbgoicgdjpfamggdegmo-Default.desktop" # Microsoft Teams PWA
          "teams-for-linux.desktop"
          "chrome-pkooggnaalmfkidjmlhoelhdllpphaga-Default.desktop" # Microsoft Outlook PWA
          # "org.keepassxc.KeePassXC.desktop"
          # "com.yubico.authenticator.desktop"
          "org.gnome.Nautilus.desktop"
          "google-chrome.desktop"
          "code.desktop"
          "idea-ultimate.desktop"
          "android-studio.desktop"
          "sublime_merge.desktop"
          "org.gnome.Console.desktop"
        ];
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };
      "org/gnome/mutter" = {
        edge-tiling = true;
        dynamic-workspaces = true;
        workspaces-only-on-primary = false;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        idle-dim = false;
        sleep-inactive-battery-timeout = 900; # 15min
        sleep-inactive-battery-type = "nothing";
        sleep-inactive-ac-timeout = 900; # 15min
        sleep-inactive-ac-type = "nothing";
        power-button-action = "interactive";
      };
      "org/gnome/desktop/session" = {
        idle-delay = 300; # 5min
      };
      "org/gnome/desktop/screensaver" = {
        lock-enabled = true;
        lock-delay = 0; # 0sec
      };
      "org/gnome/desktop/notifications" = {
        show-in-lock-screen = false;
      };

      # keybindings
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-open-terminal/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-open-filemanager/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-flameshot/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-open-terminal" = {
        name = "Open terminal";
        command = "kgx";
        binding = "<Super>r";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-open-filemanager" = {
        name = "Open file manager";
        command = "nautilus ./Downloads";
        binding = "<Super>e";
      };
      # TODO fix flameshot
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/my-flameshot" = {
        name = "Open flameshot (screenshot tool)";
        command = "flameshot gui";
        binding = "<Primary><Shift><Alt>section";
      };
    };

    xdg.userDirs = {
      enable = true;
      # setting unnecessary user directories to home dir to prevent programs to create them
      documents = "$HOME";
      music = "$HOME";
      publicShare = "$HOME";
      templates = "$HOME";
      videos = "$HOME";
    };
  };

  system.userActivationScripts.manageDefaultDirs = ''
    DIRS="Documents Music Public Templates Videos"
  
    for DIR in $DIRS; do
      echo /home/$USER
      if [ -d "/home/$USER/$DIR" ]; then
        rm -rf "/home/$USER/$DIR"
      fi
    done

    mkdir -p /home/$USER/Desktop
    mkdir -p /home/$USER/Desktop/projects
  '';
}
