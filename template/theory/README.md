# theory — 理論計算ノート (独自の研究・計算メモ)

観点ごとにフォルダを分けて tex ノートを置く。1 ノート = 1 フォルダ。

```
theory/
├── <ノート名>/
│   ├── note.tex   # 本文
│   └── fig/       # 図 (この中の PDF は git 追跡される)
└── ...
```

## 使い方

```bash
# 日本語ノート (upLaTeX)
scripts/new_note.sh theory berry_phase ja

# 英語ノート (pdfLaTeX)
scripts/new_note.sh theory berry_phase en
```

- VSCode で開いて保存すれば自動コンパイルされる (エンジンは文書クラスから自動判定)
- プリアンブル・スタイル・文献 DB は共通資産を参照するため、このフォルダには置かない
  - 数式マクロの追加 → `tex_common/common-macros.sty`
  - ノート体裁の変更 → `tex_common/note-layout.sty`
  - 文献の追加 → `survey/ref.bib`
- 中間ファイルはビルド後に自動削除され、PDF は git 管理外 (環境をクリーンに保つ)
