#!/usr/bin/env bash
# 指定した .md を tex_common/ のプリアンブル (upLaTeX) で PDF に変換する
#
# 使い方:
#   scripts/md_to_pdf.sh <file.md>
# 例:
#   scripts/md_to_pdf.sh survey/README.md
#     -> survey/README.pdf を作成 (.md と同じ場所)
# 注意:
#   同名の .pdf は上書きする (変換コマンドのため)
#   pandoc が必要 (brew install pandoc)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ $# -ne 1 ]; then
    grep '^#' "$0" | sed 's/^# \{0,1\}//' | tail -n +2
    exit 1
fi

MD="$1"

if ! command -v pandoc >/dev/null 2>&1; then
    echo "エラー: pandoc が見つかりません (brew install pandoc)" >&2
    exit 1
fi
if [ ! -f "$MD" ]; then
    echo "エラー: ファイルが見つかりません: $MD" >&2
    exit 1
fi
case "$MD" in
    *.md) ;;
    *)
        echo "エラー: .md ファイルを指定してください: $MD" >&2
        exit 1
        ;;
esac

TEMPLATE="$ROOT/tex_common/skeletons/md_pdf.tex"
if [ ! -f "$TEMPLATE" ]; then
    echo "エラー: pandoc テンプレートが見つかりません: $TEMPLATE" >&2
    exit 1
fi

MD_DIR="$(cd "$(dirname "$MD")" && pwd)"
NAME="$(basename "$MD" .md)"
TITLE="$(echo "$NAME" | tr '_' ' ')"   # _ は TeX の数式記号なのでタイトルでは空白に変換

# latexmkrc は cwd から上へ tex_common/ を探すため、ビルドはリポジトリ内の一時ディレクトリで行う
# (既存 .tex のクロバー防止も兼ねる。PDF のみを .md と同じ場所へ置く)
BUILD_DIR="$(mktemp -d "$ROOT/.md2pdf.XXXXXX")"
trap 'rm -rf "$BUILD_DIR"' EXIT

pandoc "$MD" -f gfm+tex_math_dollars -t latex \
    --template="$TEMPLATE" -M title="$TITLE" \
    -o "$BUILD_DIR/$NAME.tex"
(cd "$BUILD_DIR" && latexmk -r "$ROOT/latexmkrc" "$NAME.tex" >/dev/null)

cp "$BUILD_DIR/$NAME.pdf" "$MD_DIR/$NAME.pdf"
echo "作成しました: $MD_DIR/$NAME.pdf"
