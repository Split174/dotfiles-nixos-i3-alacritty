{
  config,
  pkgs,
  ...
}: {
  nixpkgs.config = {
    packageOverrides = pkgs: {
      mynur = import (builtins.fetchTarball "https://github.com/Split174/nur/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  users.users.serj = {
    packages = [pkgs.mynur.ygg-manager];
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;

    settings = {
      Peers = [];
      MulticastInterfaces = [];
      IfName = "ygg0";
    };
  };

  networking.firewall.interfaces."ygg0" = {
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };

  systemd.services.ygg-manager = {
    description = "Yggdrasil Smart Peer Manager";
    wantedBy = ["multi-user.target"];

    after = ["network-online.target" "yggdrasil.service"];
    wants = ["network-online.target"];
    requires = ["yggdrasil.service"];

    environment = {
      MAX_PEERS = "3";
      MAX_COST = "500";
      MAX_LATENCY_MS = "250";
      #PEER_COUNTRY = "russia";
    };

    serviceConfig = {
      Type = "simple";

      ExecStart = "${pkgs.mynur.ygg-manager}/bin/ygg-manager";

      Restart = "always";
      RestartSec = "15s";

      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;

      ReadWritePaths = ["/var/run/yggdrasil"];
    };
  };
}
