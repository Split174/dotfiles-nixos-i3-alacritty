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
    ./../modules/shells.nix
    ./../modules/homepc-syncthing.nix
    ./../modules/ygg.nix
    ./../modules/hjem.nix
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      mynur = import (builtins.fetchTarball "https://github.com/Split174/nur/archive/master.tar.gz") {
        inherit pkgs;
      };

      unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
        inherit pkgs;
      };
    };
  };

  # System Configuration
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw

  services.resolved.enable = true;

  # Boot Configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1d";
    };
    #settings = {
    #  tarball-ttl = 0;
    #};
  };

  # ssh-agent
  programs.ssh.startAgent = true;

  # Docker
  virtualisation.docker = {
    enable = true;
  };

  # Networking
  networking = {
    hostName = "homepc"; # Define your hostname.
    networkmanager.enable = true;
    #extraHosts = "${(import ../../secrets/secrets.nix).stHostsJob}";
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
  services.pulseaudio.enable = false;
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

  services.netbird.enable = true;
  #services.printing.enable = true;

  services.tailscale.enable = true;

  services.earlyoom.enable = true;

  # User Configuration
  users.defaultUserShell = pkgs.zsh;

  security.wrappers."secure-keepass-fuse" = {
    owner = "root";
    group = "root";
    capabilities = "cap_ipc_lock=+ep";

    source = "${pkgs.mynur.secure-keepass-fuse}/bin/secure-keepass-fuse";
  };

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
      yq
      xclip
      traceroute
      unzip
      zip
      flameshot
      appimage-run
      restic
      nix-init
      p7zip
      yandex-cloud
      opentofu
      terraform
      crane
      pre-commit
      nvme-cli
      fzf

      # Секерты
      sops
      gnupg
      pinentry-all
      age
      detect-secrets

      # Разработка
      tmux
      yamlfmt
      alacritty
      git
      postgresql_17
      dbeaver-bin
      zsh
      sad
      go
      gopls
      gotools
      kubectl
      kubectl-gadget
      fluxcd
      k0sctl
      argocd-vault-plugin
      kustomize_4
      sqlite
      gnumake
      (pkgs.wrapHelm pkgs.kubernetes-helm {
        plugins = [pkgs.kubernetes-helmPlugins.helm-diff];
      })
      k3d
      k9s
      argocd-autopilot

      # Коммуникации
      telegram-desktop
      mattermost-desktop
      #discord

      # Мультимедиа
      feh
      pwvucontrol
      vlc
      onlyoffice-desktopeditors
      simplescreenrecorder

      # Игры
      steam

      # Офисные программы
      keepassxc
      mynur.secure-keepass-fuse

      # Файловые менеджеры и другие
      zenity
      networkmanagerapplet
      networkmanager-openconnect
      xfce.thunar

      # Сеть
      #easytier
      alfis
      wireguard-tools
      amnezia-vpn
      mynur.dnsr
      mynur.kgb

      # IDE и текстовые редакторы
      obsidian
      unstable.zed-editor-fhs
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          jnoortheen.nix-ide
          redhat.vscode-yaml
          golang.go
          kamadorueda.alejandra
          tim-koehler.helm-intellisense
          #kilocode.kilo-code
          hashicorp.terraform
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
    nerd-fonts.fira-code
  ];

  # Program Configurations

  programs.direnv.enable = true;

  programs.gnupg.agent = {
    enable = true;
  };

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
  ];
}
