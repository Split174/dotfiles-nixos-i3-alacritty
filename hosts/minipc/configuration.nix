# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./immich.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = false;

  networking.hostName = "minipc";

  # Disable NetworkManager and configure static IP
  #networking.networkmanager.enable = false;
  networking.useDHCP = false;
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [ {
      address = "192.168.1.200";
      prefixLength = 24;
    } ];
  };
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];

  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  users.users.minipc = {
    isNormalUser = true;
    description = "minipc";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/QPeqvXNSqbmAJCYWQTkr3/8sRSOylsUPoGQDx4/W4bXZE30Q7T2GgUiRkW52V7Vy8MJwLsB5Pi6KpCgO4YcjSldThRxbyHy5bt9BGAI+QIxel2sZnFnb9hECZnXXvx+wA/X3Kj6YGI6ZjhCrk+TFwg3VkgiQQscpkIc0POs07d5EMLZtVrsnr5svmXlu7hHQ7YLk+BAsY+nLG0ydCvIGZs6dUFaib2LPmZJCwZ3TB2ryNpheRBdBK2OsqLC19dkFMtwQ0JqKqGpnUXWTeAr3VDD5x9m+FIAsBA8rX/YQF7bO8Ck8/fCS9v2FedhNbAMxNy57LHbnqWChuN98EX+63mw5oexckFr8D/4OAwPH60mUJtdG6tej+98LAYradv/FhvwNJKG83g3JRvtc07ZLq854PCFSZuIosb/wzcUHsmoqVNWDCEdOLTBj1MiagQj5dPPls0j5KSSvqTVihcM8Rffz0BC7hlKPm+O8793zuX7I5RivHWbOPR6M11y/YdU="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDc83/gvQZvSqNqYgMGwYQh2HnOio1BEv7QRqZQj2Ycb8qi+D6s7+poJ7s4v92NVy/uAUBJgJlEk4av4Robz4AIAR/X62i8R1KRYY3bwtrJ7AfS5X3+G9jt3jqaYIhcL/E8xXBoQDrcZO81qMLvzZhPKfDsFgWQsmseDs1aiO/twD+NkZpnwHMvd2Mn2nDt/TGJRiArSXvYuc2OqYbZlJ2xl4JBHGm+sYrXAxUGXPAgOJ8lkpOsfwAns1J0cqCUlEmaqabfqu7B8khVyFNCjA1GTEx+YPZa4mQGs2yOsKelhbSye7ZyLhKcMEWKnMCtcQv6/mO1m0UIPKJE8si6KwzYpdPv8+7R/HjzjUQm3gHnf7y1DGudParOPaj4boVH3Gy/WNHmwlqPzJ/5BIvSTz+4ToVJl6diT793k0JZviHfl5smUy26d4ZW2xtHZ9D8b5D1Qc0GCk4udeBJuBBDU5W1fbaMe/6aqaFIVEC2PFBhlpbg6GhWzpJUWXvwcpihAM8="
    ];
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];
  security.sudo.wheelNeedsPassword = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    vim    # Basic editor for configuration
    nano
    neofetch
  ];

  # Enable OpenSSH server with secure configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };
  
  services.fail2ban.enable = true;
  services.tailscale.enable = true;
  
  services.nginx = {
    enable = true;
    # other Nginx options
    virtualHosts."minipc.minipc.lab.home" =  {
      locations."/" = {
        proxyPass = "http://127.0.0.1:2283";
        proxyWebsockets = true; # needed if you need to use WebSocket
      };
    };
  };

  # Open SSH port in the firewall
  networking.firewall.allowedTCPPorts = [ 22 2283 80 443 ];

  system.stateVersion = "24.05";
}