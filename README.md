# Мои nixos dotfiles

Перед деплоем через мейкфайл необходимо добавить группу @wheel в trusted-users

```nix
nix.settings.trusted-users = [ "root" "serj" ];
```

### TODO

Перенести immich на podman