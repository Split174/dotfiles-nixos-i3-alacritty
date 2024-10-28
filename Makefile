TEMP_PATH = /tmp/nixos-config

# Переменные для VPS
VPS_HOST = vdsina01@89.110.119.238
VPS_CONFIG_PATH = ./hosts/vps-config
VPS_REMOTE_CONFIG_PATH = /etc/nixos

# Переменные для MINIPC
MINIPC_HOST = minipc@192.168.1.200
MINIPC_CONFIG_PATH = ./hosts/minipc
MINIPC_REMOTE_CONFIG_PATH = /etc/nixos

.PHONY: deploy-vps deploy-minipc check-vps check-minipc clean-vps clean-minipc diff-vps diff-minipc

# Команды для VPS
deploy-vps:
	# Создаём временную директорию
	ssh $(VPS_HOST) "mkdir -p $(TEMP_PATH)"
	# Копируем файлы во временную директорию
	scp -r $(VPS_CONFIG_PATH)/* $(VPS_HOST):$(TEMP_PATH)/
	# Перемещаем файлы в целевую директорию с sudo
	ssh $(VPS_HOST) "sudo cp -r $(TEMP_PATH)/* $(VPS_REMOTE_CONFIG_PATH)/ && rm -rf $(TEMP_PATH)"
	# Применяем конфигурацию
	ssh $(VPS_HOST) "sudo nixos-rebuild switch"

check-vps:
	ssh $(VPS_HOST) "nixos-version"

diff-vps:
	ssh $(VPS_HOST) "sudo nixos-rebuild dry-build"

# Команды для MINIPC
deploy-minipc:
	# Создаём временную директорию
	ssh $(MINIPC_HOST) "mkdir -p $(TEMP_PATH)"
	# Копируем файлы во временную директорию
	scp -r $(MINIPC_CONFIG_PATH)/* $(MINIPC_HOST):$(TEMP_PATH)/
	# Перемещаем файлы в целевую директорию с sudo
	ssh $(MINIPC_HOST) "sudo cp -r $(TEMP_PATH)/* $(MINIPC_REMOTE_CONFIG_PATH)/ && rm -rf $(TEMP_PATH)"
	# Применяем конфигурацию
	ssh $(MINIPC_HOST) "sudo nixos-rebuild switch"

check-minipc:
	ssh $(MINIPC_HOST) "nixos-version"

diff-minipc:
	ssh $(MINIPC_HOST) "sudo nixos-rebuild dry-build"

# Общие команды для деплоя на все хосты
deploy-all: deploy-vps deploy-minipc

check-all: check-vps check-minipc

diff-all: diff-vps diff-minipc
