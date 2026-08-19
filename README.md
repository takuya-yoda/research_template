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
copier copy gh:takuya-yoda/research_template ~/Git/<プロジェクト名>
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

### 3. 新機能を試用ブランチで検証してから配信する

見出し構成や運用が固まっていない機能は、いきなりタグを打たず**試用ブランチ**で実プロジェクトに試させ、
フィードバックを反映してから main へマージする。タグを打つまで他プロジェクトには一切配信されない。

```bash
# 1. 試用ブランチを切る（コミットは追記のみ。rebase / amend / squash merge は禁止）
cd ~/Git/research_template
git switch -c feat/<機能名>
# 編集 → commit
git push -u origin feat/<機能名>          # gh: 参照のプロジェクトがあるため push 必須

# 2. 試用プロジェクトで取り込む（working tree が clean であること）
cd ~/Git/<試用プロジェクト>
copier update --vcs-ref feat/<機能名>
git diff                                  # 確認して commit

# 3. 使ってみる → フィードバックをテンプレート側へ反映 → commit/push → 2 を再実行（何周でも可）

# 4. 確定したら main へマージしてタグを打つ（ここで初めて全プロジェクトへ配信される）
cd ~/Git/research_template
git switch main && git merge --no-ff feat/<機能名>
git tag v0.4.0 && git push && git push --tags
```

- **試用ブランチを rebase / force push しない**: `copier update` は `.copier-answers.yml` の `_commit` を
  テンプレートリポジトリから再チェックアウトして旧状態を再生成する。試用プロジェクトが取り込んだコミットを
  消すと、以後そのプロジェクトの `copier update` が「その ref が無い」で失敗する。
  同じ理由で main へは `--no-ff` マージ（squash は不可）
- **タグを打つまで未試用プロジェクトは無影響**: copier は既定で最新の非プレリリースタグを見るため、
  ブランチもプレリリースタグ (`v0.4.0-rc1` 等) も自動では配信されない
- **`--vcs-ref` はその ref までの全差分を適用する**: 試用先は先に `copier update` で最新タグまで上げておく。
  古いバージョンのまま試用ブランチを当てると、途中のタグの変更まで同時に降ってくる
- **配るのはコピー元の雛形 (`_template.md`) に限る**: `survey/notes/_template.md` や `plan/design/_template.md` の
  ように「コピーして使う」形式ならプロジェクト側が原本を編集しないため、雛形を何度改訂しても衝突しない。
  逆に中身を埋めさせる形式のファイル（`plan/research_plan.md` 等）を改訂すると全プロジェクトで衝突する
- **`ai_instructions/` を編集する場合**: `~/.claude/CLAUDE.md` がこのパスを直接 import しているため、
  ブランチをチェックアウトしている間は AI への指示自体が入れ替わる。
  `git worktree add ../research_template_dev feat/<機能名>` で別ディレクトリ作業にし、
  `~/Git/research_template` は main に固定するのが安全
- ブランチは NAS バックアップの対象に自動的に含まれる (`git bundle --all`)

### 4. テンプレートの更新を既存プロジェクトへ反映する

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

### 5. NAS 日次自動バックアップを設定する（マシンごとに 1 回）

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
- **注意 (macOS TCC)**: バックアップ先のファイルは作成元アプリに紐づき (com.apple.macl)、
  別コンテキストの launchd から置換できない。このため各プロジェクトの `scripts/backup_to_nas.sh` は
  エージェント登録済みマシンでは自動的にエージェント経由 (`launchctl kickstart`) に委譲する。
  バックアップ先 (`~/SynologyDrive/Home/Archive/Git/`) のファイルを手動で作成・編集しないこと

---

## 補足: なぜ Copier か

- **更新の伝播**: GitHub Template Repository や cookiecutter と違い、`copier update` でテンプレート更新後の差分を生成済みプロジェクトへ再適用できる（本テンプレートは継続的に改善する前提のため必須要件）
- **バージョン追跡**: `.copier-answers.yml` に生成元テンプレートの commit / 回答が記録され、git tag 単位で差分適用できる
- 同等機能を持つ cruft (cookiecutter 系) より、質問定義・バリデーション・マイグレーション機能が充実している
