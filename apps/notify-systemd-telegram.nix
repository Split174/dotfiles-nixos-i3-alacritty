{
  config,
  pkgs,
  lib,
  ...
}: let
  botToken = (import ../secrets/secrets.nix).botToken;
  chat = (import ../secrets/secrets.nix).myTGID;
in {
  systemd.services."telegram-notify@" = {
    description = "Sends a status message via Telegram on service failures.";
    path = with pkgs; [curl hostname];
    unitConfig = {
      StartLimitIntervalSec = "5m";
      StartLimitBurst = 1;
    };
    serviceConfig = {
      ExecCondition = let
        checkConditions = pkgs.writeScript "checkConditions" ''
          #!/bin/sh
          STATUS=$(systemctl status --full "$1")

          case "$STATUS" in
            *"activating (auto-restart) (Result: timeout)"*) exit 1 ;;
            *) exit 0 ;;
          esac
        '';
      in "${checkConditions} %i";

      ExecStart = let
        sendtelegram = pkgs.writeScript "sendtelegram" ''
          #!/bin/sh

          SERVICE_NAME="$1"
          HOSTNAME="$(hostname -f)"
          STATUS="$(systemctl status --full "$SERVICE_NAME")"
          MESSAGE="$(echo -e "<strong>🚨 Service Failure Alert</strong>\n\n<u>Host</u>: $HOSTNAME\n<u>Service</u>: $SERVICE_NAME\n\n<pre>$STATUS</pre>")"

          curl --silent --output /dev/null \
               --data-urlencode "chat_id=${chat}" \
               --data-urlencode "text=$MESSAGE" \
               --data-urlencode "parse_mode=HTML" \
               --data-urlencode "disable_web_page_preview=true" \
               "https://api.telegram.org/bot${botToken}/sendMessage"
        '';
      in "${sendtelegram} %i";

      Type = "oneshot";
    };
  };
}
