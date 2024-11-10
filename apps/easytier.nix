{
  config,
  pkgs,
  lib,
  ...
}: {easytierArgs}: {
  system.activationScripts.createEasyTierDir = {
    text = ''
      mkdir -p /etc/easytier
    '';
  };
  virtualisation.oci-containers = {
    containers.easytier = {
      image = "easytier/easytier:v2.0.3";
      autoStart = true;
      extraOptions = [
        "--privileged"
        "--network=host"
        "--memory=0"
        "--hostname=easytier"
      ];
      volumes = [
        "/etc/easytier:/root"
      ];
      cmd = lib.splitString " " easytierArgs;
    };
  };
  systemd.services.podman-easytier.onFailure = ["telegram-notify@%n.service"];
}
