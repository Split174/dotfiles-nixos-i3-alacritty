{
  config,
  pkgs,

  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    extraFlags = [ "--no-default-folder" ];
    user = "serj";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    configDir = "/home/serj/.config/syncthing";
    settings = {
      devices = {
        "jipok-home-server" = { id = "PADCQLR-TRHLECY-KYSCMTV-W7ZJDJQ-PLQYCE4-E6BAR2P-QOBIRZF-5BD5IQ3"; };
        "homepc" = { id = "KQQJDOX-UV5Z75P-RQATYSF-LWBBIUS-BLWXNUU-75OOY3I-SNRPBHB-PGMWVAY"; };
      };
      folders = {
        "Sync over Jipok homeserver" = {
          path = "/home/serj/sync-over-jipok-server";
          devices = [ "jipok-home-server" "homepc"];
        };
      };
    };
  };
}