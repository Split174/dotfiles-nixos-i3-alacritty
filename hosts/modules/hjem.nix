{ config, pkgs, lib, ... }:

let
  hjem-src = builtins.fetchTarball "https://github.com/feel-co/hjem/archive/main.tar.gz";
  hjem = import hjem-src { inherit pkgs; };
in
{
  imports = [
    hjem.nixosModules.hjem
  ];

  nixpkgs.overlays = [
    (final: prev: {
      smfh = hjem.packages.smfh;
    })
  ];

  hjem.users.serj = {
    enable = true;

    xdg.config.files = {

      "k9s/plugins.yaml" = {
        clobber = true;
        source = ./hjem-raw-files/k9s-plugins.yaml;
      };

      "alacritty/alacritty.yml" = {
        clobber = true;
        source = ./hjem-raw-files/alacritty.yml;
      };

      "i3/config" = {
        clobber = true;
        source = ./hjem-raw-files/i3;
      };

      "polybar/config.ini" = {
        clobber = true;
        source = ./hjem-raw-files/polybar.ini;
      };

      "polybar/launch.sh" = {
        clobber = true;
        source = ./hjem-raw-files/polybar-launch.sh;
      };
    };
  };
}
