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

    histSize = 100000;
      histFile = "$HOME/.zsh_history";
      setOptions = [
        "HIST_IGNORE_DUPS"
        "SHARE_HISTORY"
        "APPEND_HISTORY"
        "INC_APPEND_HISTORY"
        "HIST_IGNORE_SPACE"
        "EXTENDED_HISTORY"
      ];

    shellInit = ''
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh) --cmd cd"
    '';

    shellAliases = {
      zcode ="${pkgs.vscode}/bin/code $(${pkgs.zoxide}/bin/zoxide query -i)";

      mfzf = ''mv "$(fzf --height=40% --reverse --preview 'cat {}')" "$(find / -type d 2>/dev/null | fzf --height=40% --reverse)"'';

      catfzf = "${pkgs.writeShellScriptBin "catfzf-script" ''
        #!${pkgs.bash}/bin/bash

        FZF_BIN=${pkgs.fzf}/bin/fzf
        BAT_BIN=${pkgs.bat}/bin/bat

        # Инициализация переменных по умолчанию
        TARGET_DIR="."
        SKIP_FZF=0
        EXCLUDE_EXTENSIONS=()

        # Разбор аргументов командной строки
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --folder)
                    SKIP_FZF=1
                    TARGET_DIR="$2"
                    shift 2
                    ;;
                --exclude-extension)
                    EXCLUDE_EXTENSIONS+=("$2")
                    shift 2
                    ;;
                *)
                    # Если передан просто путь (для обратной совместимости)
                    TARGET_DIR="$1"
                    shift
                    ;;
            esac
        done

        if [ ! -d "$TARGET_DIR" ]; then
            echo "Ошибка: Каталог '$TARGET_DIR' не найден." >&2
            exit 1
        fi

        # Формируем дополнительные аргументы для find, чтобы исключить расширения
        FIND_ARGS=()
        for ext in "''${EXCLUDE_EXTENSIONS[@]}"; do
            # Удаляем точку в начале, если пользователь ввёл её (--exclude-extension .txt)
            ext="''${ext#.}"
            FIND_ARGS+=( "!" "-iname" "*.$ext" )
        done

        # Получаем список файлов
        if [ "$SKIP_FZF" -eq 1 ]; then
            # Просто берем все файлы рекурсивно, исключая директорию .git и нужные расширения
            selected_files=$(find "$TARGET_DIR" -type d -name .git -prune -o -type f "''${FIND_ARGS[@]}" -print)
        else
            # Проверяем fzf только если он нам нужен
            if ! command -v $FZF_BIN &> /dev/null; then
                echo "Ошибка: fzf не найден." >&2
                exit 1
            fi

            selected_files=$(find "$TARGET_DIR" -type d -name .git -prune -o -type f "''${FIND_ARGS[@]}" -print | $FZF_BIN --multi --preview "$BAT_BIN --color=always {} || cat {}")
        fi

        if [ -z "$selected_files" ]; then
            echo "Выбор отменен ни один файл не найден/не выбран."
            exit 0
        fi

        # Вывод результатов
        # Используем перенос строки как разделитель, чтобы файлы с пробелами обрабатывались корректно
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
