#!/usr/bin/env bash
# リポジトリを NAS (Synology Drive) へバックアップする
#
# 内容:
#   1. git 全履歴を 1 ファイル (<リポジトリ名>.bundle) にアトミック出力
#   2. git 管理外の保護対象 (plan/discussions/, survey/papers/) を rsync で一方向コピー
#      (--delete なし: ローカルで誤削除してもバックアップは消えない)
# 出力先:
#   ~/SynologyDrive/Home/Archive/Git/<リポジトリ名>/
#   (Synology Drive Client が NAS へ同期する)
#
# 通常は launchd により日次で自動実行される (research_template の README 参照)。
# 手動実行も可: scripts/backup_to_nas.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_NAME="$(basename "$ROOT")"
DEST_BASE="$HOME/SynologyDrive/Home/Archive/Git"
DEST="$DEST_BASE/$REPO_NAME"

# NAS 同期フォルダがないマシン (出先の PC 等) では何もせず正常終了
if [ ! -d "$DEST_BASE" ]; then
    echo "backup_to_nas: $DEST_BASE がないためスキップ ($REPO_NAME)"
    exit 0
fi

mkdir -p "$DEST"
echo "backup_to_nas: $REPO_NAME -> $DEST"

# 1. git bundle (一時ファイルに書いてから mv = 同期途中の壊れたファイルを作らない)
if git -C "$ROOT" rev-parse --quiet --verify HEAD >/dev/null 2>&1; then
    TMP_BUNDLE="$DEST/.$REPO_NAME.bundle.tmp"
    git -C "$ROOT" bundle create "$TMP_BUNDLE" --all --quiet
    mv -f "$TMP_BUNDLE" "$DEST/$REPO_NAME.bundle"
    echo "  bundle 更新: $REPO_NAME.bundle"
else
    echo "  コミットがないため bundle はスキップ"
fi

# 2. git 管理外の保護対象を一方向コピー
for sub in plan/discussions survey/papers; do
    if [ -d "$ROOT/$sub" ]; then
        mkdir -p "$DEST/$sub"
        rsync -a "$ROOT/$sub/" "$DEST/$sub/"
        echo "  rsync: $sub/"
    fi
done

echo "backup_to_nas: 完了 ($(date '+%Y-%m-%d %H:%M:%S'))"
