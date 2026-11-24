TEMP_PATH = /tmp/nixos-config

# Личный age-ключ, которым расшифровываются secrets/secrets.yaml.
# На хостах он же лежит в /etc/sops/age/keys.txt (см. hosts/modules/sops.nix).
SOPS_AGE_KEY_FILE ?= $(HOME)/.config/sops/age/keys.txt

# Переменные для VPS
VPS_HOST = vdsina01@89.110.119.238

# Переменные для MINIPC
MINIPC_HOST = minipc@192.168.1.200

# Первой сборке нужны flakes и бинарный кэш Pi, пока они ещё не прописаны в системе.
AI_NIX_OPTIONS = --option extra-experimental-features 'nix-command flakes' --option extra-substituters 'https://cache.numtide.com' --option extra-trusted-public-keys 'niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g='

.PHONY: deploy-vps deploy-minipc check-vps check-minipc clean-vps clean-minipc diff-vps diff-minipc mypc-rebuild homepc-rebuild jobpc-rebuild ai-update add-channel-vps add-channel-minipc sops-init sops-edit sops-update sops-rekey

jobpc-rebuild:
	sudo nixos-rebuild switch $(AI_NIX_OPTIONS) -I nixos-config=./hosts/job-pc/configuration.nix

homepc-rebuild:
	sudo nixos-rebuild switch $(AI_NIX_OPTIONS) -I nixos-config=./hosts/homepc/configuration.nix

# Обновить только закреплённые Pi и их зависимости, затем пересобрать хост.
ai-update:
	nix --extra-experimental-features 'nix-command flakes' flake update llm-agents --flake path:./flakes/ai

# Команды для VPS
deploy-vps:
	nixos-rebuild switch -I nixos-config=./hosts/vps-config/configuration.nix --target-host $(VPS_HOST) --use-remote-sudo

check-vps:
	ssh $(VPS_HOST) "nixos-version"

diff-vps:
	ssh $(VPS_HOST) "sudo nixos-rebuild dry-build"

add-channels:
	ssh $(VPS_HOST) "sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos"
	ssh $(MINIPC_HOST) "sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos"

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

# --- sops ---------------------------------------------------------------
# Первичная настройка: подставляет публичный age-ключ в .sops.yaml
# и создаёт зашифрованный secrets/secrets.yaml из шаблона.
sops-init:
	@test -f "$(SOPS_AGE_KEY_FILE)" || { echo "нет age-ключа: $(SOPS_AGE_KEY_FILE)"; exit 1; }
	@if grep -q AGE_PUBLIC_KEY_PLACEHOLDER .sops.yaml; then \
		pub="$$(age-keygen -y $(SOPS_AGE_KEY_FILE))"; \
		sed -i "s|AGE_PUBLIC_KEY_PLACEHOLDER|$$pub|" .sops.yaml; \
		echo "age recipient: $$pub"; \
	else \
		echo ".sops.yaml уже настроен"; \
	fi
	@if [ ! -f secrets/secrets.yaml ]; then \
		cp secrets/secrets.example.yaml secrets/secrets.yaml; \
		sops -e -i secrets/secrets.yaml; \
		echo "создан и зашифрован secrets/secrets.yaml"; \
	else \
		echo "secrets/secrets.yaml уже существует"; \
	fi

# Редактирование секретов (расшифровка на лету).
sops-edit:
	sops secrets/secrets.yaml

# Перешифровать файл после изменения списка получателей в .sops.yaml.
sops-rekey:
	sops updatekeys secrets/secrets.yaml

# Обновить пин sops-nix в hosts/modules/sops.nix до последнего master.
# master требует Go >= 1.26, а в nixpkgs 25.11 Go 1.25.5 — такой пин не соберётся.
# Поэтому без FORCE=1 обновление прервётся, если версия Go слишком новая.
sops-update:
	@rev="$$(curl -fsSL https://api.github.com/repos/Mic92/sops-nix/commits/master | sed -n 's/^ *"sha": "\([0-9a-f]\{40\}\)".*/\1/p' | head -n1)"; \
	[ -n "$$rev" ] || { echo "не удалось получить ревизию sops-nix"; exit 1; }; \
	req="$$(curl -fsSL "https://raw.githubusercontent.com/Mic92/sops-nix/$$rev/go.mod" 2>/dev/null | sed -n 's/^go \([0-9][0-9.]*\).*/\1/p' | head -n1)"; \
	if awk -v cur="$${req:-0}" 'BEGIN { exit !(cur + 0 > 1.25) }'; then \
		echo "sops-nix $$rev требует Go $$req, а в nixpkgs 25.11 — Go 1.25.5"; \
		[ "$${FORCE:-0}" = "1" ] || { echo "остановился. Если nixpkgs уже обновлён: make sops-update FORCE=1"; exit 1; }; \
	fi; \
	hash="$$(nix-prefetch-url --unpack "https://github.com/Mic92/sops-nix/archive/$$rev.tar.gz" | tail -n1)"; \
	sed -i -E "s|sops-nix/archive/[0-9a-f]{40}\.tar\.gz|sops-nix/archive/$$rev.tar.gz|; s|sha256 = \"[0-9a-z]{52}\";|sha256 = \"$$hash\";|" hosts/modules/sops.nix; \
	echo "sops-nix -> $$rev ($$hash)"
