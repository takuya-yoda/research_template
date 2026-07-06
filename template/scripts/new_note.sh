#!/usr/bin/env bash
# 新しい tex ノートを skeleton から作成する
#
# 使い方:
#   scripts/new_note.sh <置き場所> <ノート名> <ja|en>
# 例:
#   scripts/new_note.sh theory berry_phase ja
#     -> theory/berry_phase/note.tex (日本語 upLaTeX) と theory/berry_phase/fig/ を作成
#   scripts/new_note.sh survey/review gup_review en
#     -> survey/review/gup_review/note.tex (英語 pdfLaTeX) を作成
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -ne 3 ]; then
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2
    exit 1
fi

DEST_DIR="$1"
NAME="$2"
LANG_CODE="$3"

SKELETON="$ROOT/tex_common/skeletons/note_${LANG_CODE}.tex"
if [ ! -f "$SKELETON" ]; then
    echo "エラー: skeleton が見つかりません: $SKELETON (ja / en を指定)" >&2
    exit 1
fi

NOTE_DIR="$ROOT/$DEST_DIR/$NAME"
if [ -e "$NOTE_DIR/note.tex" ]; then
    echo "エラー: 既に存在します: $NOTE_DIR/note.tex" >&2
    exit 1
fi

mkdir -p "$NOTE_DIR/fig"
sed "s/__NOTE_TITLE__/$NAME/" "$SKELETON" > "$NOTE_DIR/note.tex"

echo "作成しました: $NOTE_DIR/note.tex"
echo "VSCode で開いて保存すると自動コンパイルされます (CLI: cd $DEST_DIR/$NAME && latexmk -r $ROOT/latexmkrc note.tex)"
