{
  config,
  pkgs,
  ...
}: {
  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs; [
    fzf
    bat
    zoxide
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellInit = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh) --cmd cd"
    '';

    shellAliases = {
      mfzf = ''mv "$(fzf --height=40% --reverse --preview 'cat {}')" "$(find / -type d 2>/dev/null | fzf --height=40% --reverse)"'';

      catfzf = "${pkgs.writeShellScriptBin "catfzf-script" ''
        #!${pkgs.bash}/bin/bash

        # Аргументы pkgs.fzf и pkgs.bat гарантируют, что скрипт найдёт эти программы,
        # даже если они не в PATH.
        FZF_BIN=${pkgs.fzf}/bin/fzf
        BAT_BIN=${pkgs.bat}/bin/bat

        if ! command -v $FZF_BIN &> /dev/null; then
            echo "Ошибка: fzf не найден." >&2
            exit 1
        fi

        TARGET_DIR="''${1:-.}" # Используем текущий каталог по умолчанию

        if [ ! -d "$TARGET_DIR" ]; then
            echo "Ошибка: Каталог '$TARGET_DIR' не найден." >&2
            exit 1
        fi

        selected_files=$(find "$TARGET_DIR" \( -name .git -type d \) -prune -o -type f -print | $FZF_BIN --multi --preview "$BAT_BIN --color=always {} || cat {}")

        if [ -z "$selected_files" ]; then
            echo "Выбор отменен."
            exit 0
        fi

        # Вывод результатов
        IFS=$'\n'
        for file in $selected_files; do
            echo "''${file}:"
            echo
            echo '```'
            cat "''${file}"
            echo '```'
            echo ""
        done
      ''}/bin/catfzf-script";
    };

    ohMyZsh = {
      enable = true;
      plugins = ["git" "fzf" "docker" "docker-compose" "podman" "systemd" "helm" "kubectl"];
      theme = "robbyrussell";
    };
  };
}
