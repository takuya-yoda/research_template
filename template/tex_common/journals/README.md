# tex_common/journals — ジャーナル配布のクラス/スタイル置場

ここに置いたファイルは latexmkrc の `TEXINPUTS` (tex_common// 再帰) 経由で
どのノート/論文フォルダからも自動で見つかる。

## 入手方法

| ジャーナル | 必要ファイル | 入手先 |
|---|---|---|
| APS 系 (PRL/PRB/PRD/PRX 等) | revtex4-2.cls ほか | **TeX Live 同梱** (`kpsewhich revtex4-2.cls` で確認。配置不要) |
| JHEP | jheppub.sty | **同梱済み** (`journals/jhep/jheppub.sty`, LPPL ライセンス)。最新版は JHEP 公式サイト (jhep.sissa.it) の "TeX class" ページ |
| PTEP | ptephy.cls ほか | PTEP (OUP) の Author Guidelines ページから LaTeX テンプレート zip を取得し、`journals/ptep/` に展開 |

## 配置

```
tex_common/journals/
├── jhep/jheppub.sty   # 同梱済み
└── ptep/ptephy.cls    # 各自で配置
```
