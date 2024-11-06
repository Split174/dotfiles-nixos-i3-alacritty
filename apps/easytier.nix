{ config, pkgs, lib, ... }:

{easytierArgs}:

{
  system.activationScripts.createEasyTierDir = {
    text = ''
      mkdir -p /etc/easytier
    '';
  };
  virtualisation.oci-containers = {
    containers.easytier = {
      image = "easytier/easytier:latest";
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
      cmd = lib.splitString " " easytierArgs;  # Разбиваем строку аргументов на массив
    };
  };
}
