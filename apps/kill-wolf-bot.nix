{
  config,
  pkgs,
  lib,
  ...
}: {token}: {
  virtualisation.podman.defaultNetwork.settings = {dns_enabled = true;};

  virtualisation.oci-containers = {
    containers = {
      "kill-wolf-bot" = {
        image = "cr.10.144.144.2.sslip.io:80/telegram-gatekeeper-bot:0.0.1";
        autoStart = true;
        environment = {
          TELEGRAM_BOT_TOKEN = "${token}";
          REDIS_CONNECTION_STRING = "redis://kill-wolf-bot-redis:6379";
        };
      };
      "kill-wolf-bot-redis" = {
        image = "redis:7.2.6-bookworm";
        autoStart = true;
      };
    };
  };

  systemd.services."podman-kill-wolf-bot".onFailure = ["telegram-notify@%n.service"];
}
