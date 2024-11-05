{ config, lib, pkgs, ... }:

let
  immichVersion = "v1.119.1";
  immichLibrary = "/etc/immich/library";
  pgData = "/etc/immich/postgresql";
  dbPass = (import ../../secrets/secrets.nix).immichDBPass;
  dbUser = "immich";
  dbName = "postgres";
  immichPort = "2283";
  composeFile = pkgs.writeText "docker-compose.yaml" ''
    name: immich

    services:
      immich-server:
        container_name: immich_server
        image: ghcr.io/immich-app/immich-server:${immichVersion}
        volumes:
          - ${immichLibrary}:/usr/src/app/upload
          - /etc/localtime:/etc/localtime:ro
        environment:
          UPLOAD_LOCATION: ${immichLibrary}
          DB_USERNAME: ${dbUser}
          DB_PASSWORD: ${dbPass}
          DB_DATABASE_NAME: ${dbName}
        ports:
          - ${immichPort}:${immichPort}
        depends_on:
          - database
        restart: always
        healthcheck:
          disable: false

      redis:
        container_name: immich_redis
        image: docker.io/redis:6.2-alpine@sha256:2ba50e1ac3a0ea17b736ce9db2b0a9f6f8b85d4c27d5f5accc6a416d8f42c6d5
        healthcheck:
          test: redis-cli ping || exit 1
        restart: always

      database:
        container_name: immich_postgres
        image: docker.io/tensorchord/pgvecto-rs:pg14-v0.2.0@sha256:90724186f0a3517cf6914295b5ab410db9ce23190a2d9d0b9dd6463e3fa298f0
        environment:
          POSTGRES_PASSWORD: ${dbPass}
          POSTGRES_USER: ${dbUser}
          POSTGRES_DB: ${dbName}
          POSTGRES_INITDB_ARGS: '--data-checksums'
        volumes:
          - ${pgData}:/var/lib/postgresql/data
        healthcheck:
          test: pg_isready --dbname=${dbName} --username=${dbUser} || exit 1; Chksum="$$(psql --dbname=${dbName} --username=${dbUser} --tuples-only --no-align --command='SELECT COALESCE(SUM(checksum_failures), 0) FROM pg_stat_database')"; echo "checksum failure count is $$Chksum"; [ "$$Chksum" = '0' ] || exit 1
          interval: 5m
          start_interval: 30s
          start_period: 5m
        command:
          [
            'postgres',
            '-c',
            'shared_preload_libraries=vectors.so',
            '-c',
            'search_path="$$user", public, vectors',
            '-c',
            'logging_collector=on',
            '-c',
            'max_wal_size=2GB',
            '-c',
            'shared_buffers=512MB',
            '-c',
            'wal_compression=on',
          ]
        restart: always
  '';
in
{
  system.activationScripts.createImmichDir = {
    text = ''
      mkdir -p /etc/immich
    '';
  };
  systemd.services.immich-docker = {
    description = "Immich Docker Compose Service";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/etc/immich";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} up -d";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} down";
    };
  };
  virtualisation.docker.enable = true;
}
