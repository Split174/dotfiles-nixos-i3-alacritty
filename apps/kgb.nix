{
  config,
  pkgs,
  lib,
  ...
}: {
  systemd.services.kgb = {
    description = "KGB service with specific country allowlist";

    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    path = with pkgs; [
      nftables
      wget
    ];

    serviceConfig = {
      ExecStart = "${pkgs.mynur.kgb}/bin/kgb --allow ru,nl";

      User = "root";

      Type = "simple";

      Restart = "always";
      RestartSec = "30s";
    };
  };
}
