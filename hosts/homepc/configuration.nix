# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../apps/node-exporter.nix
    (import ../../apps/easytier.nix {inherit config pkgs lib;} {
      easytierArgs = "-d --network-name ${(import ../../secrets/secrets.nix).easytierName} --network-secret ${(import ../../secrets/secrets.nix).easytierSecret} -p udp://89.110.119.238:11010";
    })
  ];

  # System Configuration
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw

  # Boot Configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Docker
  virtualisation.docker.enable = true;

  system.activationScripts."dockerLogin" = {
    text = ''${pkgs.docker}/bin/docker login -u ${(import ../../secrets/secrets.nix).dockerUser} -p ${(import ../../secrets/secrets.nix).dockerPass}'';
  };

  # Networking
  networking = {
    hostName = "homepc"; # Define your hostname.
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Time and Locale
  time.timeZone = "Asia/Yekaterinburg";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_IDENTIFICATION = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_NUMERIC = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
      LC_TIME = "ru_RU.UTF-8";
    };
  };

  # X11 and Desktop Environment
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
    };
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        rofi
        i3status
        i3lock
        i3blocks
        dmenu
      ];
    };
  };

  # Sound
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
    # media-session.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # User Configuration
  users.defaultUserShell = pkgs.zsh;

  users.users.serj = {
    isNormalUser = true;
    description = "serj";
    extraGroups = ["networkmanager" "wheel" "docker"];

    packages = with pkgs; [
      # Утилиты
      neofetch
      wget
      curl
      jq
      xclip
      traceroute
      unzip
      zip
      flameshot
      appimage-run
      restic

      # Разработка
      alacritty
      git
      zsh
      go
      gopls
      gotools
      kubectl
      gnumake
      (pkgs.wrapHelm pkgs.kubernetes-helm {
        plugins = [pkgs.kubernetes-helmPlugins.helm-diff];
      })
      k3d
      k9s

      # Коммуникации
      telegram-desktop
      mattermost-desktop
      #discord

      # Мультимедиа
      feh
      pwvucontrol

      # Игры
      steam

      # Офисные программы
      keepassxc

      # Файловые менеджеры и другие
      networkmanagerapplet
      networkmanager-openconnect
      xfce.thunar

      # Сеть
      #easytier
      wireguard-tools

      # IDE и текстовые редакторы
      obsidian
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          jnoortheen.nix-ide
          redhat.vscode-yaml
          golang.go
          kamadorueda.alejandra
          tim-koehler.helm-intellisense
          phind.phind
          ms-python.python
        ];
      })
    ];
  };

  # Environment Variables
  environment.variables = rec {
    GIT_AUTHOR_NAME = "Split174";
    GIT_AUTHOR_EMAIL = "sergei.popov174@gmail.com";
    GIT_COMMITTER_NAME = "Split174";
    GIT_COMMITTER_EMAIL = "sergei.popov174@gmail.com";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerdfonts
  ];

  # Shell Configuration
  environment.shells = with pkgs; [zsh];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = ["git" "docker" "docker-compose" "podman" "systemd" "helm" "kubectl"];
      theme = "robbyrussell";
    };
  };

  # Program Configurations
  programs = {
    firefox.enable = true;
    steam.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        # thunar-archive-plugin
        # thunar-volman
      ];
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    # vim
    # wget
    # vscode
    # i3status
    helix
  ];

  # Optional Configurations (commented out)
  # services.xserver.libinput.enable = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # services.openssh.enable = true;
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;
}
