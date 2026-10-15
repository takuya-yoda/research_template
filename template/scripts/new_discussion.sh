#!/usr/bin/env bash
# 新しい議論記録フォルダを作成する
#
# 使い方:
#   scripts/new_discussion.sh <トピック>
# 例:
#   scripts/new_discussion.sh gup_definition
#     -> docs/discussions/20260706_gup_definition/memo.md を作成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -ne 1 ]; then
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2
    exit 1
fi

TOPIC="$1"
TODAY="$(date +%F)"
STAMP="$(date +%Y%m%d)"               # フォルダ名は YYYYMMDD_ (運用規則の日付フォルダと同じ形)
DIR="$ROOT/docs/discussions/${STAMP}_${TOPIC}"

if [ -e "$DIR/memo.md" ]; then
    echo "エラー: 既に存在します: $DIR/memo.md" >&2
    exit 1
fi

mkdir -p "$DIR"
cat > "$DIR/memo.md" <<EOF
# 議論記録: $TOPIC

- 日付: $TODAY
- 参加者:

## 要点

-

## 決定事項 / TODO

-
EOF

echo "作成しました: $DIR/memo.md"
echo "黒板写真 (.pdf/.jpg) も同じフォルダへ (git-annex)。docs/log.md にも 1 行残すこと"
echo "NAS へ送る: git annex add . → commit → git annex sync --content nas"
