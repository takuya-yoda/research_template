# machine_setup

新しいマシン（またはサーバ）で研究環境を揃えるための資産と手順。

## AI 指示（ai_instructions/）の有効化

Claude Code に執筆・作業指示（`ai_instructions/instructions.md`）を常時適用させる手順。

```sh
# 1. テンプレートリポジトリを標準パスに配置
gh repo clone takuya-yoda/research_template ~/Git/research_template

# 2. グローバル CLAUDE.md から import（1 行追記）
mkdir -p ~/.claude
cat >> ~/.claude/CLAUDE.md <<'EOF'

## 執筆・作業指示（正典: research_template/ai_instructions/）
@~/Git/research_template/ai_instructions/instructions.md
EOF
```

- import はセッション開始時に読み込まれる。指示の更新は `git pull` 後の次セッションから反映される
- 他 PC から VSCode Remote-SSH で接続する場合、Claude Code は SSH 先で動くため、SSH 先でこの設定が済んでいれば追加作業は不要

## バックアップ（NAS）

廃止（2026-09-28）。プロジェクトの正本を NAS の bare リポジトリ + git-annex に移したため不要となり、
`com.yoda.git-nas-backup.plist` と `run_all_backups.sh` を削除した。
