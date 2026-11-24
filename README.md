# Мои nixos dotfiles

Перед деплоем необходимо добавить группу @wheel в trusted-users

```nix
nix.settings.trusted-users = [ "root" "serj" ];
```

## Pi и nono

`hosts/modules/ai.nix` устанавливает `pi` и `nono` системно на homepc и jobpc
из `flakes/ai/flake.nix`. `pi` запускается напрямую; алиас `pi-nono` запускает
Pi в профиле nono `pi` с доступом на запись к текущему каталогу, как и прежний
алиас. Аргументы передаются без изменений. После пересборки открой новый shell
или выполни `exec zsh`, чтобы старые алиасы исчезли.

Версии закреплены в `flakes/ai/flake.lock`: это отдельный flake для пакетов,
а не перевод всей конфигурации на flakes. Остальная система по-прежнему
собирается из канала, а VPS и minipc не изменены. Зашифрованные секреты и тем
более локальный `secrets/secrets.nix` в этот flake не входят.

```console
make homepc-rebuild   # либо make jobpc-rebuild
pi --version
nono --version
pi-nono              # из каталога проекта

make ai-update       # обновить flake.lock
make homepc-rebuild  # установить обновления (либо jobpc-rebuild)
```

Закоммить оба файла `flakes/ai/flake.nix` и `flakes/ai/flake.lock`, чтобы на
других компьютерах использовались те же версии. В модуле настроен подписанный
бинарный кэш Numtide: первое скачивание происходит при пересборке, не при
каждом запуске Pi. Если нужной сборки в кэше нет, Nix может собрать её локально.
Запуск `pi-nono` по-прежнему ограничен профилем nono; при необходимости доступа
за пределы текущего проекта настрой отдельный профиль.

### Получить пиры easytier

`
sudo podman exec easytier /bin/sh -c - 'easytier-cli peer'
`

### Список снапшотов:

```
export export RCLONE_CONFIG='/etc/restic/rclone.conf' && export RESTIC_PASSWORD=PASS && restic -r rclone:yandex:immich snapshots
export export RCLONE_CONFIG='/etc/restic/rclone.conf' && export RESTIC_PASSWORD=PASS && restic -r rclone:yandex:immich restore latest --target ./test
```
## Секреты (sops-nix)

Секреты лежат в `secrets/secrets.yaml` — файл **зашифрован** и коммитится в git.
В `/nix/store` попадает только шифротекст, открытые значения появляются в рантайме
в `/run/secrets/<name>`. Расшифровка делается личным age-ключом хоста
`/etc/sops/age/keys.txt` (root:root, 0400).

Подключение: `hosts/modules/sops.nix` (пиннутая ревизия sops-nix через `builtins.fetchTarball`).
Живой пример использования: `hosts/modules/xray.nix` — xray-клиент, у которого в sops лежат и VLESS `uuid`, и все endpoint-параметры
(адрес, порты, REALITY publicKey/shortId/spiderX/serverName, путь HTTPUpgrade).

Пин стоит на ревизии от 2026-09-01, а не на master, по двум причинам:
- master требует Go >= 1.26, а в nixpkgs 25.11 — Go 1.25.5 (`GOTOOLCHAIN=local` → сборка падает);
- в master дефолты `sshKeyPaths` обращаются к `services.openssh.generateHostKeys`, которого нет в 25.11
  (обходится явными `age.sshKeyPaths` / `gnupg.sshKeyPaths = []` в модуле).

После обновления nixpkgs на версию с Go >= 1.26 можно брать master: `make sops-update FORCE=1`.

### Первичная настройка

1. Создать `secrets/secrets.yaml` и подставить публичный age-ключ в `.sops.yaml`:

   ```console
   make sops-init      # публичный ключ берётся из ~/.config/sops/age/keys.txt
   ```

2. Заполнить реальные значения:

   ```console
   sops secrets/secrets.yaml   # редактор откроется с расшифрованным файлом
   ```

3. Положить age-ключ на каждый хост (без него не будет расшифровки):

   ```console
   # локально
   sudo install -d -m 0700 /etc/sops/age
   sudo install -m 0400 /dev/stdin /etc/sops/age/keys.txt < ~/.config/sops/age/keys.txt

   # удалённый хост
   ssh HOST 'sudo install -d -m 0700 /etc/sops/age && sudo install -m 0400 /dev/stdin /etc/sops/age/keys.txt' \
     < ~/.config/sops/age/keys.txt
   ```

4. Пересобрать хост: `make homepc-rebuild` / `make jobpc-rebuild`.

### Добавить новый секрет

```console
# 0. положить значение
sops secrets/secrets.yaml
```

```nix
# 1. объявить в nix
sops.secrets.myToken = {};

# 2. использовать
systemd.services.foo.serviceConfig.EnvironmentFile = config.sops.secrets.myToken.path;
# или подставить в файл через шаблон:
sops.templates."foo.conf".content = ''token=${config.sops.placeholder.myToken}'';
```

Полезные опции секрета: `owner`, `group`, `mode`, `restartUnits`, `neededForUsers`.

### Полезные команды

```console
sops secrets/secrets.yaml                    # редактировать
sops -d secrets/secrets.yaml                 # посмотреть расшифровку
sops updatekeys secrets/secrets.yaml         # перешифровать после правки .sops.yaml
make sops-update                             # обновить пин sops-nix
sudo cat /run/secrets/<name>                 # проверить, что секрет установлен
sudo cat /run/secrets/rendered/xray.json     # отрендеренный конфиг xray
```

### Диагностика

| Симптом | Причина |
| --- | --- |
| `no age identity found` / activation падает на setupSecrets | нет `/etc/sops/age/keys.txt` или ключ не тот |
| `secret <name> in ... is not valid` при сборке | ключа нет в `secrets/secrets.yaml` (опечатка или забыл добавить) |
| `sops-install-secrets: failed to decrypt` | файл зашифрован не на этот age-ключ → `sops updatekeys` |
| `go.mod requires go >= 1.26` при сборке | пин sops-nix не совпадает с Go в nixpkgs (см. выше) |

### Безопасность

- `secrets/secrets.nix` (старый формат, открытый) — в `.gitignore`, но он всё равно
  подмешивался в `/nix/store` при сборке. Переноси значения в `secrets.yaml` и удаляй.
- Один личный age-ключ лежит на всех хостах: компрометация любого из них = доступ ко всем секретам.
  Если это станет проблемой — генерируй пер-хостовые ключи и добавляй их получателями в `.sops.yaml`.
- Значения, которые уже были в гите/конфигах (например VLESS `uuid`), стоит ротировать.

### TODO

Перенести immich на podman