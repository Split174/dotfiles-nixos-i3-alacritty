# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
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
    #(import ../../apps/easytier.nix {inherit config pkgs lib;} {
    #  easytierArgs = "-d --network-name ${(import ../../secrets/secrets.nix).easytierName} --network-secret ${(import ../../secrets/secrets.nix).easytierSecret} -p udp://89.110.119.238:11010 --exit-nodes 10.144.144.1";
    #})
  ];
  nixpkgs.config = {
    packageOverrides = pkgs: {
      mynur = import (builtins.fetchTarball "https://github.com/Split174/nur/archive/master.tar.gz") {
        inherit pkgs;
      };
      #unstable = import (builtins.fetchTarball "https://github.com/nixos/nixpkgs/tarball/master") {
      #  inherit pkgs;
      #};
    };
  };

  # System Configuration
  system.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  environment.pathsToLink = ["/libexec"]; # links /libexec from derivations to /run/current-system/sw

  # Boot Configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Docker

  virtualisation.docker.enable = true;

  # Networking
  networking = {
    hostName = "jobpc"; # Define your hostname.
    networkmanager.enable = true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    #extraHosts = ''
    #${(import ../../secrets/secrets.nix).extraHostsJob}
    #'';
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

  # resolvectl
  services.resolved.enable = true;

  services.tailscale.enable = true;

  # User Configuration
  users.defaultUserShell = pkgs.zsh;
  users.users.serj = {
    isNormalUser = true;
    description = "serj";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      neofetch
      alacritty
      mc
      lm_sensors

      telegram-desktop
      mattermost-desktop
      zoom-us
      obsidian
      keepassxc
      (pkgs.pass.withExtensions (exts: [ exts.pass-otp ]))
      argocd
      argocd-autopilot
      argocd-vault-plugin
      jq
      age
      detect-secrets
      pre-commit

      fzf
      mynur.dnsr

      #медия
      feh
      vlc
      onlyoffice-desktopeditors
      p7zip
      sniffnet

      postgresql_16
      #dbeaver-bin
      #pgweb
      zip
      zsh
      bat
      git
      kubectl
      (pkgs.wrapHelm pkgs.kubernetes-helm {
        plugins = [pkgs.kubernetes-helmPlugins.helm-diff];
      })
      k3d
      gnumake
      k9s
      yamllint
      yamlfmt
      yq
      yandex-cloud
      kustomize_4

      opentofu
      ansible
      nix-init

      go
      gopls
      gotools

      gparted

      restic

      xclip

      pinentry-curses
      sops
      gnupg

      traceroute
      headscale
      doggo
      wireguard-tools
      pwvucontrol

      arandr
      obs-studio

      networkmanagerapplet
      networkmanager-openconnect
      xfce.thunar
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          bbenoist.nix
          redhat.vscode-yaml
          tim-koehler.helm-intellisense
          golang.go
          yzhang.markdown-all-in-one
          hashicorp.terraform
        ];
      })

      unzip
      flameshot
      xfce.mousepad
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
    shellAliases = {
      mfzf = ''mv "$(fzf --height=40% --reverse --preview 'cat {}')" "$(find / -type d 2>/dev/null | fzf --height=40% --reverse)"'';
    };
    oh-my-zsh = {
      enable = true;
      plugins = ["git" "fzf"];
      theme = "robbyrussell";
    };
  };

  # Program Configurations
  programs = {
    gnupg.agent.enable = true;
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
