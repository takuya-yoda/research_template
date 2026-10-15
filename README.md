# research_template

物理研究の企画用 Copier 雛形。
文献調査 (survey) / 理論計算ノート (theory) / Python 開発 (code) / 研究計画 (plan) /
論文執筆 (paper) / 過去資産の保管 (archive) を 1 束で管理する構成を生成する。

この束は責任 `40_Areas/43_Tooling/research_template`。正本は NAS、窓口は GitHub (`takuya-yoda/research_template`)。
`~/` の運用規則（層・束・同期・立項）の正典は `~/00_System/00_Management/00.00_JDex/`。本書は雛形固有の手順のみを書く。

## 前提ツール

| ツール | インストール |
|---|---|
| uv | `brew install uv` |
| copier | `uv tool install copier` |
| pandoc | `brew install pandoc`（`scripts/md_to_pdf.sh` 用） |
| TeX Live (uplatex / pdflatex / latexmk) | MacTeX 等 |
| VSCode + LaTeX Workshop 拡張 | 保存時自動コンパイル用 |

---

## 操作手順

### 1. 研究企画を立項する

立項の列（フォルダ作成 → `git init` → `git annex init` → `project.yml` → NAS の bare → 初期 commit → 同期）は
`1-30_Projects.md`「企画を立項する」が正典。雛形から作る分岐は次の 1 行:

```bash
copier copy gh:takuya-yoda/research_template ~/30_Projects/<cat>/<slug>
```

- `copier` は GitHub（窓口）の最新タグを取得する。雛形を直したら窓口に送ってから立項する
- 質問（プロジェクト名・著者情報）に答えると一式が生成される。日常の使い方は生成された `README.md` に書いてある
- `project.yml` は雛形に含めない。立項の列で `00.03_Templates/project.yml` を複製する

### 2. 雛形自体を更新する

編集して commit し、**バージョンタグ**を打って同期する。
copier は既定で最新タグを使うため、タグを打つまで各企画には配信されない。

```bash
cd ~/40_Areas/43_Tooling/research_template
# 編集...
git add -A && git commit -m "research_template: <何を変えた>"   # 前置は slug (2-sync.md)
git tag v0.4.0                                                 # セマンティックバージョニング
git annex sync --content nas && git push nas --tags            # 正本へ（annex sync はタグを送らない）
git push origin main && git push origin --tags                 # 窓口へ
```

- 同期（`annex sync` `push`）は人が打つ（guard hook が Claude の実行を止める。`2-guard.md`）
- 確かめる列は `2-sync.md`。タグは `git ls-remote --tags nas` と `git ls-remote --tags origin` が一致すること

### 3. 新機能を試用ブランチで検証してから配信する

見出し構成や運用が固まっていない機能は、いきなりタグを打たず**試用ブランチ**で実企画に試させ、
フィードバックを反映してから main へマージする。タグを打つまで他の企画には一切配信されない。

```bash
# 1. 試用ブランチを切る（コミットは追記のみ。rebase / amend / squash merge は禁止）
cd ~/40_Areas/43_Tooling/research_template
git switch -c feat/<機能名>
# 編集 → commit
git annex sync --content nas && git push -u origin feat/<機能名>   # gh: 参照の企画があるため窓口へも送る

# 2. 試用する企画で取り込む（working tree が clean であること）
cd ~/30_Projects/<cat>/<slug>
copier update --vcs-ref feat/<機能名>
git diff                                  # 確認して commit

# 3. 使ってみる → フィードバックを雛形側へ反映 → commit/同期 → 2 を再実行（何周でも可）
#    気づいた点は企画側の plan/template_feedback.md に溜まる。ここから拾って雛形を直す
#    cat ~/30_Projects/*/*/plan/template_feedback.md

# 4. 確定したら main へマージしてタグを打つ（ここで初めて全企画へ配信される）
cd ~/40_Areas/43_Tooling/research_template
git switch main && git merge --no-ff feat/<機能名>
# 以後は 手順 2 のタグ・同期の列
```

- **試用ブランチを rebase / force push しない**: `copier update` は `.copier-answers.yml` の `_commit` を
  雛形リポジトリから再チェックアウトして旧状態を再生成する。試用した企画が取り込んだコミットを
  消すと、以後その企画の `copier update` が「その ref が無い」で失敗する。
  同じ理由で main へは `--no-ff` マージ（squash は不可）
- **タグを打つまで未試用の企画は無影響**: copier は既定で最新の非プレリリースタグを見るため、
  ブランチもプレリリースタグ (`v0.4.0-rc1` 等) も自動では配信されない
- **`--vcs-ref` はその ref までの全差分を適用する**: 試用先は先に `copier update` で最新タグまで上げておく。
  古いバージョンのまま試用ブランチを当てると、途中のタグの変更まで同時に降ってくる
- **配るのはコピー元の雛形 (`_requirements.md` `_design.md` `_template.md`) に限る**: 「コピーして使う」形式なら
  企画側が原本を編集しないため、雛形を何度改訂しても衝突しない。
  逆に中身を埋めさせる形式のファイル（`plan/research_plan.md` 等）を改訂すると全企画で衝突する
- **`ai_instructions/` を編集する場合**: `~/.claude/CLAUDE.md` がこのパスを直接 import しているため、
  ブランチをチェックアウトしている間は AI への指示自体が入れ替わる。
  作業コピーは 1 機器に 1 つ（worktree で増やさない。`1-40_Areas.md`）なので、
  `ai_instructions/` を触るブランチは短命にし、直ちに main へマージする

### 4. 雛形の更新を既存の企画へ反映する

各企画側で `copier update` を実行する（`1-30_Projects.md`「雛形の更新を取り込む」）。

```bash
cd ~/30_Projects/<cat>/<slug>
git status --short        # 空であること
copier update             # 最新タグとの差分だけが 3-way merge で適用される
git diff                  # 反映内容を確認して commit
```

- 企画側で編集済みのファイルも差分マージされる。競合時は `.rej` / インラインマーカーが残るので手動解決する
- どのバージョンから生成されたかは各企画の `.copier-answers.yml` に記録されている（手動編集しない）
- 質問の回答を変えたい場合は `copier update --data author_email=...` のように上書きできる
- 保管済みの束（`50_Archives`）は更新しない（中身を編集しない規則。`1-50_Archives.md`）

### 5. 同期（正本と窓口）

生成された各企画の正本は NAS の bare リポジトリ、GitHub は窓口。列は `2-sync.md`。

- 議論記録の写真・PDF (plan/discussions/) と文献 PDF (survey/papers/) は git-annex で管理する
  （規則は `template/.gitattributes`）。本体は NAS に置かれ、GitHub には symlink のみが載る
- 前提: 各企画で `git annex init` を済ませていること（立項の列に含まれる）。
  済ませていない clone で `git add` すると、写真・PDF が Git 本体に入り GitHub に載る
- 窓口から clone した共同研究者には `scripts/setup_collaborator.sh` を実行させる（誤 commit を pre-commit で止める）
- launchd による日次バックアップは NAS 正本化に伴い 2026-09-28 に廃止した（`5-decisions.md`）

---

## 補足: なぜ Copier か

- **更新の伝播**: GitHub Template Repository や cookiecutter と違い、`copier update` で雛形更新後の差分を生成済みの企画へ再適用できる（本雛形は継続的に改善する前提のため必須要件）
- **バージョン追跡**: `.copier-answers.yml` に生成元の commit / 回答が記録され、git tag 単位で差分適用できる
- 同等機能を持つ cruft (cookiecutter 系) より、質問定義・バリデーション・マイグレーション機能が充実している
