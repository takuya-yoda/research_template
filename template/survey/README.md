# survey — 業界研究 (他者の結果のまとめ)

| 場所 | 内容 | git 管理 |
|---|---|---|
| `papers/` | 参照頻度の高い文献 PDF のローカル保管 | ✗ (管理外) |
| `notes/` | 論文 1 本ごとの要約 md (`notes/_template.md` をコピー) | ✓ |
| `review/` | 複数の結果を独自の視点でまとめ直す tex ノート | ✓ |
| `ref.bib` | 文献データベース (全ノート・論文から共通参照) | ✓ |
| `glossary.md` | 学術用語の裏付け付き定義キャッシュ (`/term` が参照・追記) | ✓ |

## 使い方

```bash
# 論文要約を書く
cp survey/notes/_template.md survey/notes/<bibkey>.md

# 独自視点のレビューノートを作る (en の例)
scripts/new_note.sh survey/review gup_review en
```

- PDF は `papers/` に置く。git には上がらない (.gitignore 済) ので、必要なら arXiv 番号を md に記録しておく
- `ref.bib` の bibkey と `notes/` のファイル名を揃えると管理しやすい
