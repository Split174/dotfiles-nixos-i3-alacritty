{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./networking.nix # generated at runtime by nixos-infect

  ];

  boot.tmp.cleanOnBoot = true;
  zramSwap.enable = true;
  networking.hostName = "v120888";
  networking.domain = "hosted-by-vdsina.com";

  users.users.vdsina01 = {
    isNormalUser = true;
    description = "vdsina01";
    extraGroups = [ 
      "wheel" 
    #  "docker" 
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/QPeqvXNSqbmAJCYWQTkr3/8sRSOylsUPoGQDx4/W4bXZE30Q7T2GgUiRkW52V7Vy8MJwLsB5Pi6KpCgO4YcjSldThRxbyHy5bt9BGAI+QIxel2sZnFnb9hECZnXXvx+wA/X3Kj6YGI6ZjhCrk+TFwg3VkgiQQscpkIc0POs07d5EMLZtVrsnr5svmXlu7hHQ7YLk+BAsY+nLG0ydCvIGZs6dUFaib2LPmZJCwZ3TB2ryNpheRBdBK2OsqLC19dkFMtwQ0JqKqGpnUXWTeAr3VDD5x9m+FIAsBA8rX/YQF7bO8Ck8/fCS9v2FedhNbAMxNy57LHbnqWChuN98EX+63mw5oexckFr8D/4OAwPH60mUJtdG6tej+98LAYradv/FhvwNJKG83g3JRvtc07ZLq854PCFSZuIosb/wzcUHsmoqVNWDCEdOLTBj1MiagQj5dPPls0j5KSSvqTVihcM8Rffz0BC7hlKPm+O8793zuX7I5RivHWbOPR6M11y/YdU="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDc83/gvQZvSqNqYgMGwYQh2HnOio1BEv7QRqZQj2Ycb8qi+D6s7+poJ7s4v92NVy/uAUBJgJlEk4av4Robz4AIAR/X62i8R1KRYY3bwtrJ7AfS5X3+G9jt3jqaYIhcL/E8xXBoQDrcZO81qMLvzZhPKfDsFgWQsmseDs1aiO/twD+NkZpnwHMvd2Mn2nDt/TGJRiArSXvYuc2OqYbZlJ2xl4JBHGm+sYrXAxUGXPAgOJ8lkpOsfwAns1J0cqCUlEmaqabfqu7B8khVyFNCjA1GTEx+YPZa4mQGs2yOsKelhbSye7ZyLhKcMEWKnMCtcQv6/mO1m0UIPKJE8si6KwzYpdPv8+7R/HjzjUQm3gHnf7y1DGudParOPaj4boVH3Gy/WNHmwlqPzJ/5BIvSTz+4ToVJl6diT793k0JZviHfl5smUy26d4ZW2xtHZ9D8b5D1Qc0GCk4udeBJuBBDU5W1fbaMe/6aqaFIVEC2PFBhlpbg6GhWzpJUWXvwcpihAM8="
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #virtualisation.docker.enable = true;

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
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

  # Headscale
  services.headscale = {
    enable = true;
    address = "0.0.0.0";
    port = 80;
    user = "vdsina01";
    settings = {
      server_url = "https://head.themiple.ru:80";
    };
  };
  services.fail2ban.enable = true;
  services.tailscale.enable = true;
  # Open SSH port in the firewall
  networking.firewall.allowedTCPPorts = [ 22 80 ];

  system.stateVersion = "24.05";
}