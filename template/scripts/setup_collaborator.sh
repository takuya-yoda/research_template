#!/usr/bin/env bash
# GitHub (窓口) から clone した共同研究者向けの初期設定 (clone ごとに 1 回)
#
# 使い方:
#   scripts/setup_collaborator.sh
#
# 内容 (変更は .git/ の中だけ。他の人には影響しない):
#   pre-commit hook を置き、次の commit を止める
#     - 議論記録の写真・PDF (docs/discussions/)、文献 PDF (survey/papers/)、実験の結果 (code/experiments/*/results/) の追加
#     - 10 MB を超えるファイルの追加
#     - symlink (git-annex 管理のファイル) の追加・変更・削除
#   (.git/info/exclude は .gitignore の否定規則より弱く、PDF を隠せないので使わない)
#
# 背景: 正本は NAS にあり、上記のファイルは git-annex で管理している (README.md 参照)。
# git-annex を初期化済みの clone (正本側) では何もしない。
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GIT_DIR="$(git -C "$ROOT" rev-parse --absolute-git-dir)"
MARK="# research_template: setup_collaborator"

if [ -n "$(git -C "$ROOT" config --get annex.uuid || true)" ]; then
    echo "git-annex が初期化済みのため何もしません (正本側の clone)"
    exit 0
fi

# pre-commit hook
HOOK="$GIT_DIR/hooks/pre-commit"
mkdir -p "$GIT_DIR/hooks"
if [ -e "$HOOK" ] && ! grep -qF "$MARK" "$HOOK"; then
    echo "警告: 既存の pre-commit hook があるため上書きしません: $HOOK" >&2
    echo "      写真・PDF・10 MB 超・symlink の変更は手で確認してください" >&2
    exit 1
fi
cat > "$HOOK" <<'EOF'
#!/usr/bin/env bash
# research_template: setup_collaborator
# 写真・PDF・10 MB を超えるファイルと symlink (git-annex 管理) の変更を commit させない
shopt -s nocasematch
LIMIT=$((10 * 1024 * 1024))
ng=0
while IFS= read -r -d '' meta && IFS= read -r -d '' path; do
    read -r oldmode newmode _ newsha _ <<<"${meta#:}"
    if [ "$oldmode" = 120000 ] || [ "$newmode" = 120000 ]; then
        echo "NG (symlink = git-annex 管理のファイル): $path" >&2
        ng=1
    elif [ "$newmode" != 000000 ] && [ "$newmode" != 160000 ]; then
        case "$path" in
            docs/discussions/*.pdf|docs/discussions/*.jpg|docs/discussions/*.jpeg|docs/discussions/*.png|docs/discussions/*.heic)
                echo "NG (議論記録の写真・PDF): $path" >&2; ng=1; continue ;;
            code/experiments/*/results/*)
                echo "NG (実験の結果): $path" >&2; ng=1; continue ;;
            survey/papers/.gitkeep) ;;
            survey/papers/*)
                echo "NG (文献 PDF): $path" >&2; ng=1; continue ;;
        esac
        size=$(git cat-file -s "$newsha")
        if [ "$size" -gt "$LIMIT" ]; then
            echo "NG (10 MB 超: $((size / 1024 / 1024)) MB): $path" >&2
            ng=1
        fi
    fi
done < <(git diff --cached --raw --no-renames --no-abbrev -z)

if [ "$ng" -ne 0 ]; then
    cat >&2 <<'MSG'

commit を止めました。
- 大きなファイル・写真・PDF は commit せず、管理者へ渡してください
- symlink は触らないでください。取り消し: git restore --staged <path> && git restore <path>
詳細は README.md「大きなファイル・写真・PDF の扱い」
MSG
    exit 1
fi
EOF
chmod +x "$HOOK"
echo "hook: 設置しました ($HOOK)"
echo "完了"
