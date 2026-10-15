# Issue tracker: docs/issues/ の markdown

このリポジトリの issue と spec は `docs/issues/` の markdown ファイルで管理する。GitHub Issues は使わない（remote が GitHub でも `gh issue` を呼ばない）。
スキルの本文が local tracker の既定 `.scratch/<feature-slug>/` を名指ししたときは、以下の `docs/issues/<YYYYMMDD>_<名前>/` に読み替える。`.scratch/` は作らない（`.gitignore` で除外してある）。

## 規約

- 1 主題 = 1 ファイル: `docs/issues/<YYYYMMDD>_<名前>.md`。日付は起票日、名前は英小文字と `-`
- 主題ファイルは方針メモとして人が書き始め、同じファイルを書き直して育てる。段階は冒頭の `Status:` 行で示す。文字列は triage role（`triage-labels.md`）に従う

    | `Status:` | 主題ファイルの段階 |
    |---|---|
    | `needs-triage` | 方針メモ。人が書いた粗い方針で、grill の入力 |
    | `needs-info` | grill の途中で、利用者の回答・調査待ちの問いが残っている |
    | `ready-for-agent` | 仕様が確定した版。`/grill-with-docs` の結論を書き戻したもの、または `/to-spec` の雛形で書き直したもの |
    | `closed` | 実施済み。結果と受入確認を記録した最終形 |

    - `closed` は triage role ではない。upstream が完了を「issue を close する」操作で表すことに合わせた、ファイル管理での代替
    - 対応しないと決めた主題は `wontfix`

- チケットは 1 件 1 ファイル: `docs/issues/<YYYYMMDD>_<名前>/<NN>-<slug>.md`。主題ファイルと同名のフォルダに置き、`01` から依存順（blocker が先）に番号を振る。1 つのファイルにまとめない
- チケットも冒頭付近の `Status:` 行に同じ文字列を書く。`/to-tickets` が作るチケットは `ready-for-agent` で始まり、実装が済んだら `closed` にする。依存は `Blocked by:` 行に書く
- コメントと経緯は、ファイル末尾の `## Comments` 見出しの下に追記する

## スキルが「issue tracker に publish する」と言うとき

- spec: 既存の主題ファイルを書き直し、`Status:` を `ready-for-agent` にする。**新しいファイルを作らない**。主題ファイルが無い場合のみ新規作成する
- チケット: 主題ファイルと同名のフォルダに、上記の規約で 1 件 1 ファイルを作る
- 主題ファイルの元の版は git 履歴に残るので、複写を残さない

## スキルが「該当チケットを取得する」と言うとき

参照されたパスのファイルを読む。利用者はパスかチケット番号を直接渡す。

## Wayfinder の操作

`/wayfinder` が使う。**map** は 1 ファイルで、チケットごとに **child** ファイルを持つ。

- Map: `docs/issues/<YYYYMMDD>_<名前>/map.md`（Notes / Decisions-so-far / Fog）
- Child: `docs/issues/<YYYYMMDD>_<名前>/<NN>-<slug>.md`。`Type:` 行（`research` / `prototype` / `grilling` / `task`）と `Status:` 行（`claimed` / `resolved`）を持つ
- Blocking: 冒頭付近の `Blocked by: NN, NN` 行。列挙したファイルがすべて `resolved` なら unblocked
- Frontier: フォルダ内の open・unblocked・unclaimed のファイル。番号の若いものを先に取る
- Claim: 作業前に `Status: claimed` を書いて保存する
- Resolve: `## Answer` 見出しの下に答えを追記し、`Status: resolved` にして、`map.md` の Decisions-so-far に要点とリンクを追記する

## 他のスキルの出力先

- `research` の調査ノート: `survey/notes/<YYYYMMDD>_<topic>.md`（論文要約と同じ場所。`survey/README.md`）
- `prototype` の成果物: `code/experiments/<YYYYMMDD>_<名前>/`（1 問い = 1 フォルダ。`code/experiments/README.md`）
- `handoff`: OS の一時ディレクトリ（リポジトリには置かない）
