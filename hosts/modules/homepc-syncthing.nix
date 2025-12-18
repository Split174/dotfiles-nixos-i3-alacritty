{
  config,
  pkgs,
  ...
}: {
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    extraFlags = ["--no-default-folder"];
    user = "serj";
    overrideDevices = true;
    overrideFolders = true;
    configDir = "/home/serj/.config/syncthing";
    settings = {
      devices = {
        "jipok-home-server" = {id = "PADCQLR-TRHLECY-KYSCMTV-W7ZJDJQ-PLQYCE4-E6BAR2P-QOBIRZF-5BD5IQ3";};
        "jobpc" = {id = "PCGJHVK-EYUCQZU-NSSHYHR-25ZK6FG-MT6BXEQ-D5W6P5V-HDH2XBV-ZA6BUQ7";};
      };
      folders = {
        "Sync over Jipok homeserver" = {
          path = "/home/serj/sync-over-jipok-server";
          devices = ["jipok-home-server" "jobpc"];
        };
      };
    };
  };
}
