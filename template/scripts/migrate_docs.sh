#!/usr/bin/env bash
# 雛形 v0.5.0 への移行: plan/ を docs/ に改名し、要件定義書・設計書の雛形を外す
#
# 使い方:
#   scripts/migrate_docs.sh            # 実行 (working tree が clean であること)
#   scripts/migrate_docs.sh --dry-run  # 何をするかだけ表示
# 手順 (このスクリプトは v0.5.0 が配るため、update 前の束には無い。雛形の作業コピーから複写する):
#   0. cp ~/40_Areas/43_Tooling/research_template/template/scripts/migrate_docs.sh scripts/
#   1. scripts/migrate_docs.sh → git diff --cached で確認 → git commit (このスクリプトは add しない。copier update が配る)
#   2. copier update               (v0.5.0 の差分が docs/ に対して当たる)
# 内容 (すべて git mv / git rm。履歴は保たれる):
#   - plan/ → docs/ (research_plan.md log.md discussions/ template_feedback.md)
#   - plan/design/_requirements.md _design.md README.md を削除 (案件フォルダ plan/design/<案件>/ は docs/design/ に移すだけで消さない)
#   - code/experiments/ を作る
#   - 文書内の plan/ 参照を docs/ に置換 (log.md template_feedback.md discussions/**/*.md)
# 注意:
#   docs/ が既にある束 (自前で作った場合) は停止する。手で統合してから再実行する
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
DRY=0
[ "${1:-}" = "--dry-run" ] && DRY=1

run() { if [ "$DRY" -eq 1 ]; then echo "+ $*"; else echo "+ $*"; "$@"; fi; }

if [ ! -d plan ]; then
    echo "plan/ が無いため何もしません (移行済み)"
    exit 0
fi
if [ -d docs ]; then
    echo "エラー: docs/ が既に存在します。手で統合してから再実行してください" >&2
    exit 1
fi
if [ -n "$(git status --short --untracked-files=no)" ] && [ "$DRY" -eq 0 ]; then   # 未追跡 (このスクリプト自身) は許す
    echo "エラー: working tree が clean ではありません" >&2
    exit 1
fi

for f in plan/design/_requirements.md plan/design/_design.md plan/design/README.md; do
    [ -f "$f" ] && run git rm -q "$f"
done
if [ -d plan/design ] && [ -z "$(ls -A plan/design 2>/dev/null)" ]; then
    run rmdir plan/design
fi
run git mv plan docs
run mkdir -p code/experiments

# 文書内の参照を置換 (plan/ → docs/)。tex は触らない
if [ "$DRY" -eq 0 ]; then
    git ls-files -z docs README.md CLAUDE.md 2>/dev/null | grep -z -E '\.md$' | while IFS= read -r -d '' f; do
        if grep -q 'plan/' "$f"; then
            sed -i '' -e 's#plan/discussions#docs/discussions#g; s#plan/log\.md#docs/log.md#g; s#plan/research_plan\.md#docs/research_plan.md#g; s#plan/template_feedback\.md#docs/template_feedback.md#g' "$f"
            git add "$f"
            echo "+ sed plan/ -> docs/: $f"
        fi
    done
else
    echo "+ sed plan/ -> docs/ in docs/**/*.md README.md CLAUDE.md"
fi

echo
echo "完了。次に: git diff --cached --stat → git commit -m \"<slug>: plan/ を docs/ へ移行\" (このスクリプトは add しない) → copier update"
