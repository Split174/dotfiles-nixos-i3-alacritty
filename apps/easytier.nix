# easytier.nix
{ config, pkgs, lib, ... }:

{easytierArgs}: 

{
  systemd.services.easytier = {
    description = "EasyTier Service";
    after = [ "network.target" "syslog.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.easytier}/bin/easytier-core ${easytierArgs}";
      Restart = "on-failure";
    };
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    easytier
  ];
}