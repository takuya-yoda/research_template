#!/usr/bin/env bash
# ~/Git 配下の全プロジェクトの backup_to_nas.sh を順次実行する
# (launchd から日次で呼ばれる。手動実行も可)
set -u

GIT_DIR="$HOME/Git"
echo "===== run_all_backups: $(date '+%Y-%m-%d %H:%M:%S') ====="

status=0
for script in "$GIT_DIR"/*/scripts/backup_to_nas.sh; do
    [ -f "$script" ] || continue
    if ! bash "$script" --direct; then
        echo "!!! 失敗: $script" >&2
        status=1
    fi
done

echo "===== run_all_backups: 終了 (status=$status) ====="
exit $status
