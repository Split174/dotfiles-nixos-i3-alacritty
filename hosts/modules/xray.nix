# Xray-клиент: локальные SOCKS5 (1080 / 1081) → VLESS на сервер из sops
#   reality-out     — основной канал (VLESS REALITY, tcp)
#   httpupgrade-out — резервный (VLESS + TLS + HTTPUpgrade)
#
# Здесь остаются только структура, routing и локальные порты.
# Всё, что описывает сервер (адрес, порты, reality-параметры, путь),
# лежит в secrets/secrets.yaml и попадает в конфиг в рантайме;
# в /nix/store остаются лишь placeholder'ы.
{
  config,
  pkgs,
  lib,
  ...
}: let
  ph = config.sops.placeholder;

  # Порт в JSON обязан быть числом, а placeholder — строка.
  # Поэтому кладём в порты маркеры и после toJSON снимаем кавычки:
  #   "port":"%xray-reality-port%"  →  "port":<SOPS:...:PLACEHOLDER>
  # sops-install-secrets заменит placeholder на число, и JSON станет валидным.
  json = let
    raw = builtins.toJSON {
      log = {
        loglevel = "warning";
      };

      # Локальные входы (SOCKS5 прокси на твоем ПК)
      inbounds = [
        {
          tag = "socks-reality";
          listen = "127.0.0.1";
          port = 1080; # Твой основной SOCKS5
          protocol = "socks";
          settings = {
            udp = true;
            auth = "noauth";
          };
        }
        {
          tag = "socks-httpupgrade";
          listen = "127.0.0.1";
          port = 1081; # Резервный SOCKS5
          protocol = "socks";
          settings = {
            udp = true;
            auth = "noauth";
          };
        }
      ];

      # Подключения к твоему серверу
      outbounds = [
        # 1. Основной канал: VLESS REALITY (быстрый)
        {
          tag = "reality-out";
          protocol = "vless";
          settings = {
            vnext = [
              {
                address = ph.xrayServer;
                port = "%xray-reality-port%";
                users = [
                  {
                    # секрет: sops.secrets.xrayVlessUuid
                    id = ph.xrayVlessUuid;
                    encryption = "none";
                  }
                ];
              }
            ];
          };
          streamSettings = {
            network = "tcp";
            security = "reality";
            realitySettings = {
              show = false;
              fingerprint = "firefox";
              serverName = ph.xrayRealityServerName;
              publicKey = ph.xrayRealityPublicKey;
              shortId = ph.xrayRealityShortId;
              spiderX = ph.xrayRealitySpiderX;
            };
          };
        }

        # 2. Резервный канал: VLESS HTTP Upgrade
        {
          tag = "httpupgrade-out";
          protocol = "vless";
          settings = {
            vnext = [
              {
                address = ph.xrayServer;
                port = "%xray-httpupgrade-port%";
                users = [
                  {
                    # секрет: sops.secrets.xrayVlessUuid
                    id = ph.xrayVlessUuid;
                    encryption = "none";
                  }
                ];
              }
            ];
          };
          streamSettings = {
            network = "httpupgrade";
            security = "tls";
            tlsSettings = {
              serverName = ph.xrayServer;
              fingerprint = "firefox";
            };
            httpupgradeSettings = {
              path = ph.xrayHttpupgradePath;
              host = ph.xrayServer;
            };
          };
        }
      ];

      # Правило маршрутизации: связываем локальный порт с сервером
      routing = {
        domainStrategy = "AsIs";
        rules = [
          {
            type = "field";
            inboundTag = ["socks-reality"];
            outboundTag = "reality-out";
          }
          {
            type = "field";
            inboundTag = ["socks-httpupgrade"];
            outboundTag = "httpupgrade-out";
          }
        ];
      };
    };
  in
    builtins.replaceStrings
    ["\"%xray-reality-port%\"" "\"%xray-httpupgrade-port%\""]
    [ph.xrayRealityPort ph.xrayHttpupgradePort]
    raw;
in {
  sops.secrets = {
    # Кредитка VLESS
    xrayVlessUuid = {};

    # Описание сервера (endpoint)
    xrayServer = {};
    xrayRealityPort = {};
    xrayHttpupgradePort = {};
    xrayRealityPublicKey = {};
    xrayRealityShortId = {};
    xrayRealitySpiderX = {};
    xrayRealityServerName = {};
    xrayHttpupgradePath = {};
  };

  sops.templates."xray.json" = {
    # Если конфиг/секрет поменялся — перезапустить xray.
    restartUnits = ["xray.service"];
    content = json;
  };

  services.xray = {
    enable = true;
    # JSON собирается sops-nix'ом в рантайме, чтобы секреты не попали в store.
    settingsFile = config.sops.templates."xray.json".path;
  };
}
