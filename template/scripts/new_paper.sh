#!/usr/bin/env bash
# 新しい論文草稿を ジャーナル別 skeleton から作成する
#
# 使い方:
#   scripts/new_paper.sh <論文名> <aps-revtex|jhep|ptep>
# ジャーナルの選び方:
#   aps-revtex : PRL / PRA-PRE / PRB / PRD / PRX / PRResearch など APS 系 (revtex4-2)
#   jhep       : JHEP (要 jheppub.sty -> tex_common/journals/README.md)
#   ptep       : PTEP (投稿時に公式クラスへ切替 -> tex_common/journals/README.md)
# 例:
#   scripts/new_paper.sh gup_chern aps-revtex
#     -> paper/gup_chern/main.tex と paper/gup_chern/fig/ を作成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -ne 2 ]; then
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2
    exit 1
fi

NAME="$1"
JOURNAL="$2"

SKELETON="$ROOT/tex_common/skeletons/paper_${JOURNAL}.tex"
if [ ! -f "$SKELETON" ]; then
    echo "エラー: skeleton が見つかりません: $SKELETON (aps-revtex / jhep / ptep を指定)" >&2
    exit 1
fi

PAPER_DIR="$ROOT/paper/$NAME"
if [ -e "$PAPER_DIR/main.tex" ]; then
    echo "エラー: 既に存在します: $PAPER_DIR/main.tex" >&2
    exit 1
fi

mkdir -p "$PAPER_DIR/fig"
TITLE="$(echo "$NAME" | tr '_' ' ')"
sed "s/__PAPER_TITLE__/$TITLE/" "$SKELETON" > "$PAPER_DIR/main.tex"

echo "作成しました: $PAPER_DIR/main.tex (journal: $JOURNAL)"
echo "共同執筆・投稿段階での分離手順は paper/README.md を参照"
