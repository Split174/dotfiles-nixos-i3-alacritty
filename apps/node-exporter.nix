{
  config,
  pkgs,
  lib,
  ...
}: let
  configure_prom = builtins.toFile "prometheus.yml" ''
    scrape_configs:
    - job_name: '${config.networking.hostName}'
      stream_parse: true
      static_configs:
      - targets:
        - 127.0.0.1:9100
  '';
in {
  services.prometheus.exporters.node.enable = true;

  systemd.services.export-to-prometheus = {
    path = with pkgs; [victoriametrics];
    enable = true;
    wantedBy = ["multi-user.target"];
    script = "vmagent -promscrape.config=${configure_prom} -remoteWrite.url=http://10.144.144.2:8428/api/v1/write";
  };
}
