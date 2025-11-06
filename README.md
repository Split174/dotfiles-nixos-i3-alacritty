# Мои nixos dotfiles

Перед деплоем необходимо добавить группу @wheel в trusted-users

```nix
nix.settings.trusted-users = [ "root" "serj" ];
```

### Получить пиры easytier

`
sudo podman exec easytier /bin/sh -c - 'easytier-cli peer'
`

### Список снапшотов:

```
export export RCLONE_CONFIG='/etc/restic/rclone.conf' && export RESTIC_PASSWORD=PASS && restic -r rclone:yandex:immich snapshots
export export RCLONE_CONFIG='/etc/restic/rclone.conf' && export RESTIC_PASSWORD=PASS && restic -r rclone:yandex:immich restore latest --target ./test
```
### TODO

Перенести immich на podman