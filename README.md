# Dotfiles Setup

Этот скрипт настраивает dotfiles, перемещая конфигурации nix, i3 и i3status в директорию `~/dotfiles/` и создавая символические ссылки для их использования.

## Installation

   ```bash
   git clone https://github.com/Split174/split174-nixos-i3.git
   cd split174-nixos-i3
   ```

   ```bash
   chmod +x setup_dotfiles.sh
   ```

   ```bash
   ./setup_dotfiles.sh
   ```

## Примечания

- Убедитесь, что у вас есть необходимые права для выполнения команд с `sudo`.
- Скрипт предполагает, что у вас уже есть конфигурационные файлы i3 и i3status в `~/.config/i3/` и `~/.config/i3status/` соответственно.
- Если вы хотите изменить пути или настройки, отредактируйте скрипт перед запуском.