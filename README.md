# Мои dotfiles

Репо с dotfiles, скрипт setup-dotfiles.sh перемещает конфигурации nix, i3 и i3status в директорию `~/dotfiles/` и создаёт для них симлинки.

## Установка

   ```bash
   git clone https://github.com/Split174/split174-dotfiles.git ~/dotfiles
   cd dotfiles
   ```

   ```bash
   chmod +x setup_dotfiles.sh
   ```

   ```bash
   ./setup_dotfiles.sh
   ```

## Примечания

- Убедитесь, что у вас есть необходимые права для выполнения команд с `sudo`.
- Скрипт предполагает, что у вас уже есть конфигурационные файлы i3, i3status и alacritty в `~/.config/i3/`, `~/.config/i3status/` и `~/.config/alacritty` соответственно.
- Если вы хотите изменить пути или настройки, отредактируйте скрипт перед запуском.