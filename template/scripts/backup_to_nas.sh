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
#
# 注意 (macOS TCC): バックアップ先のファイルには作成元アプリに紐づく com.apple.macl が
# 付与され、別コンテキスト (launchd) から置換できなくなる。このため launchd エージェントが
# 登録済みのマシンでは、手動実行もエージェント経由に委譲してコンテキストを統一する。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_NAME="$(basename "$ROOT")"
DEST_BASE="$HOME/SynologyDrive/Home/Archive/Git"
DEST="$DEST_BASE/$REPO_NAME"
AGENT="com.yoda.git-nas-backup"

# launchd エージェントがあれば委譲 (エージェント自身からは --direct で呼ばれる)
if [ "${1:-}" != "--direct" ] && launchctl print "gui/$(id -u)/$AGENT" >/dev/null 2>&1; then
    echo "launchd エージェント経由で全リポジトリをバックアップします"
    launchctl kickstart "gui/$(id -u)/$AGENT"
    echo "ログ: ~/Library/Logs/git-nas-backup.log"
    exit 0
fi

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
