# paper — 論文執筆

初期草稿は本リポジトリ内で書き、共同執筆・投稿の段階で Overleaf 連携の別リポジトリへ分離する。

## 1. 草稿を始める

```bash
scripts/new_paper.sh <論文名> <aps-revtex|jhep|ptep>
```

| 投稿先 | skeleton |
|---|---|
| PRL / PRA-PRE / PRB / PRD / PRX / PRResearch (APS 系) | `aps-revtex` (revtex4-2) |
| JHEP | `jhep` (要 jheppub.sty → tex_common/journals/README.md) |
| PTEP | `ptep` (投稿時に公式クラスへ切替) |

草稿段階では共通資産をそのまま使える (書き直し不要):

- 数式マクロ: `tex_common/common-macros.sty` (ノートと共通。論文執筆中にマクロを足す場合もここ)
- 文献 DB: `survey/ref.bib`
- 図: ノートで作った `fig/` の PDF や `code/` の生成図を流用

## 2. 共同執筆・投稿段階で分離する

Overleaf の Git 連携などで共同執筆する際は、self-contained な別リポジトリに切り出す:

```bash
# 分離先を用意 (例: Overleaf で空プロジェクトを作り git clone する)
DEST=<分離先ディレクトリ>

cp paper/<論文名>/main.tex        "$DEST"/
cp -r paper/<論文名>/fig          "$DEST"/fig
cp tex_common/common-macros.sty   "$DEST"/
cp tex_common/utphys.bst          "$DEST"/   # utphys を使う場合のみ
cp survey/ref.bib                 "$DEST"/
# JHEP/PTEP のクラスファイルを使っている場合は tex_common/journals/ からもコピー
```

分離後の運用:

- 分離先が正本になる。本リポジトリの `paper/<論文名>/` には分離先の URL を書いた `MOVED.md` を残す
- 共通マクロを分離先で変更した場合は、必要に応じて `tex_common/common-macros.sty` に手動で還元する
- 出版が決まったら、公開コードの切り出しは `code/README.md` の手順を参照
