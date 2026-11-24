# sops-nix: секреты расшифровываются в рантайме, а не при сборке.
#
# Что это меняет:
#   - раньше `import ../secrets/secrets.nix` подставлял пароли прямо в деривации,
#     и они оказывались в /nix/store (world-readable) + в истории сборок;
#   - теперь в /nix/store лежит только шифротекст secrets/secrets.yaml,
#     а открытые значения появляются в /run/secrets/<name> при активации.
#
# Как пользоваться (кратко, подробности в README.md):
#   make sops-init        # подставить age-ключ в .sops.yaml и создать secrets.yaml
#   sops secrets/secrets.yaml
#   sops.secrets.<name> = {};                                  # объявить секрет
#   config.sops.secrets.<name>.path                            # путь /run/secrets/<name>
#   config.sops.placeholder.<name>                             # вставить в sops.templates
#
# Личный age-ключ лежит на хосте в /etc/sops/age/keys.txt (root:root, 0400).
# В git он НЕ попадает.
{
  config,
  pkgs,
  lib,
  ...
}: let
  # --- sops-nix, зафиксированная ревизия -------------------------------------
  # Обновление: `make sops-update` (перепишет url и sha256 ниже).
  #
  # Пин на ревизию от 2026-09-01, а не на master: master требует Go >= 1.26,
  # а в nixpkgs 25.11 Go 1.25.5 (GOTOOLCHAIN=local → сборка падает).
  # При обновлении nixpkgs до версии с Go >= 1.26 можно снова брать master.
  sops-nix-src = builtins.fetchTarball {
    url = "https://github.com/Mic92/sops-nix/archive/a8627b21b9107c5711c96b84f32a9a4b3d45295f.tar.gz";
    sha256 = "1j89yslxj0q29xzrjcp19r4a130k4cdihx4yw6f2bm72fgia0j42";
  };
in {
  imports = ["${sops-nix-src}/modules/sops"];

  sops = {
    # Единый файл секретов для всех хостов. Он зашифрован и коммитится в git.
    defaultSopsFile = ../../secrets/secrets.yaml;

    # На этапе сборки проверяем, что каждый объявленный sops.secrets.<name>
    # реально существует в secrets.yaml (ловит опечатки без расшифровки).
    validateSopsFiles = true;

    age = {
      # Личный age-ключ, положенный на хост вручную (см. README).
      keyFile = "/home/serj/.config/sops/age/keys.txt";
      # Не подмешиваем ssh-хостовые ключи: единственный источник — age-ключ.
      # Задаём явно, иначе вычисляется дефолт из sshd-модуля.
      sshKeyPaths = [];
    };

    # То же для gpg-ветки: sops-nix в дефолте `gnupg.sshKeyPaths` обращается к
    # config.services.openssh.generateHostKeys, которого больше нет в 25.11.
    # gpg нам не нужен, поэтому жёстко пусто — заодно обходим этот баг.
    gnupg.sshKeyPaths = [];
  };
}
