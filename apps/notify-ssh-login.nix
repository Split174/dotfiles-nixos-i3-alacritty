{...}: let
  botToken = (import ../secrets/secrets.nix).botToken;
  chat = (import ../secrets/secrets.nix).myTGID;
in {
  environment.etc."ssh/sshrc" = {
    mode = "755";
    text = ''
      export LANG=C
      TELEGRAM_CHAT_ID="${chat}"
      TELEGRAM_BOT_TOKEN="${botToken}"
      LOGGED_USER="$(whoami)"
      LOGGED_HOST="$(hostname -f)"
      SERVER_IP="$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -n1 | awk '{print $2}' | cut -d/ -f1)"

      LOGGED_IP=''${SSH_CONNECTION%% *}
      LOGGED_TTY="$(ps -p "$$" -o tname h)"

      NOW="$(date)"
      MESSAGE="$(echo -e "<strong>⚠️ SSH Login Notification ⚠️</strong>\n\n<u>Host</u>: $LOGGED_HOST ($SERVER_IP)\n<u>User</u>: $LOGGED_USER\n<u>User IP</u>: $LOGGED_IP\n<u>Time</u>: $NOW")"

      curl --silent --output /dev/null \
                    --data-urlencode "chat_id=$TELEGRAM_CHAT_ID" \
                    --data-urlencode "text=$MESSAGE" \
                    --data-urlencode "parse_mode=HTML" \
                    --data-urlencode "disable_web_page_preview=true" \
                    "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage"
    '';
  };
}
