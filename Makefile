TEMP_PATH = /tmp/nixos-config

# Переменные для VPS
VPS_HOST = vdsina01@89.110.119.238
VPS_CONFIG_PATH = ./hosts/vps-config
VPS_REMOTE_CONFIG_PATH = /etc/nixos

# Переменные для MINIPC
MINIPC_HOST = minipc@192.168.1.200
MINIPC_CONFIG_PATH = ./hosts/minipc
MINIPC_REMOTE_CONFIG_PATH = /etc/nixos

.PHONY: deploy-vps deploy-minipc check-vps check-minipc clean-vps clean-minipc diff-vps diff-minipc mypc-rebuild homepc-rebuild

homepc-rebuild:
	sudo nixos-rebuild switch -I nixos-config=./hosts/homepc/configuration.nix

# Команды для VPS
deploy-vps:
	nixos-rebuild switch -I nixos-config=./hosts/vps-config/configuration.nix --target-host $(VPS_HOST) --use-remote-sudo

check-vps:
	ssh $(VPS_HOST) "nixos-version"

diff-vps:
	ssh $(VPS_HOST) "sudo nixos-rebuild dry-build"

# Команды для MINIPC
deploy-minipc:
	nixos-rebuild switch -I nixos-config=./hosts/minipc/configuration.nix  --target-host $(MINIPC_HOST) --use-remote-sudo

check-minipc:
	ssh $(MINIPC_HOST) "nixos-version"

diff-minipc:
	ssh $(MINIPC_HOST) "sudo nixos-rebuild dry-build"

# Общие команды для деплоя на все хосты
deploy-all: deploy-vps deploy-minipc

check-all: check-vps check-minipc

diff-all: diff-vps diff-minipc
