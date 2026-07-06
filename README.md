# research_template

物理研究プロジェクト用の Copier テンプレート。
文献調査 (survey) / 理論計算ノート (theory) / Python 開発 (code) / 研究計画 (plan) /
論文執筆 (paper) / 過去資産の保管 (archive) を 1 リポジトリで管理する構成を生成する。

## 前提ツール

| ツール | インストール |
|---|---|
| uv | `brew install uv` |
| copier | `uv tool install copier` |
| TeX Live (uplatex / pdflatex / latexmk) | MacTeX 等 |
| VSCode + LaTeX Workshop 拡張 | 保存時自動コンパイル用 |

---

## 操作手順

### 1. 新規プロジェクトを作る

```bash
copier copy gh:yoddycd/research_template ~/Git/<プロジェクト名>
# ローカルから作る場合
copier copy ~/Git/research_template ~/Git/<プロジェクト名>
```

質問（プロジェクト名・著者情報など）に答えると一式が生成される。
生成後は各プロジェクトの README.md に日常の使い方（ノート作成・自動コンパイル・uv）を記載している。

```bash
cd ~/Git/<プロジェクト名>
git init && git add -A && git commit -m "Initialize from research_template"
cd code && uv sync        # Python 環境構築
```

### 2. テンプレート自体を更新する

このリポジトリを編集して commit し、**バージョンタグ**を打って push する。
copier はデフォルトで最新タグを使うため、タグを打つまで各プロジェクトには配信されない。

```bash
cd ~/Git/research_template
# 編集...
git add -A && git commit -m "変更内容"
git tag v0.2.0            # セマンティックバージョニング
git push && git push --tags
```

### 3. テンプレートの更新を既存プロジェクトへ反映する

各プロジェクト側で `copier update` を実行する（working tree が clean であること）。

```bash
cd ~/Git/<プロジェクト名>
git status                # clean を確認
copier update             # 最新タグとの差分だけが 3-way merge で適用される
git diff                  # 反映内容を確認して commit
```

- プロジェクト側で編集済みのファイルも差分マージされる。競合時は `.rej` / インラインマーカーが残るので手動解決する
- どのバージョンから生成されたかは各プロジェクトの `.copier-answers.yml` に記録されている（手動編集しない）
- 質問の回答を変えたい場合は `copier update --data author_email=...` のように上書きできる

### 4. NAS 日次自動バックアップを設定する（マシンごとに 1 回）

生成された各プロジェクトは NAS への日次自動バックアップを前提に運用する。
各プロジェクトの `scripts/backup_to_nas.sh` が git 全履歴 (bundle) と git 管理外の保護対象
(plan/discussions/ の写真、survey/papers/ の文献 PDF) を
`~/SynologyDrive/Home/Archive/Git/<リポジトリ名>/` へ一方向コピーする
（作業リポジトリを SynologyDrive 内に置くと同期で .git が壊れうるため、この方式にしている）。

launchd で毎日 12:00 に `~/Git` 配下の全プロジェクトを一括バックアップする設定:

```bash
cp ~/Git/research_template/machine_setup/com.yoda.git-nas-backup.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.yoda.git-nas-backup.plist
```

- 動作確認: `launchctl kickstart gui/$(id -u)/com.yoda.git-nas-backup` → `~/Library/Logs/git-nas-backup.log` を確認
- 解除: `launchctl bootout gui/$(id -u)/com.yoda.git-nas-backup`
- 新しいプロジェクトを作っても追加設定は不要（`~/Git/*/scripts/backup_to_nas.sh` を自動で拾う）

---

## 補足: なぜ Copier か

- **更新の伝播**: GitHub Template Repository や cookiecutter と違い、`copier update` でテンプレート更新後の差分を生成済みプロジェクトへ再適用できる（本テンプレートは継続的に改善する前提のため必須要件）
- **バージョン追跡**: `.copier-answers.yml` に生成元テンプレートの commit / 回答が記録され、git tag 単位で差分適用できる
- 同等機能を持つ cruft (cookiecutter 系) より、質問定義・バリデーション・マイグレーション機能が充実している
