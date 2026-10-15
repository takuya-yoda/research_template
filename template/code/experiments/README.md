# experiments — 実験

1 つの問いに答えるための、コード・結果・レポートの組を置く。1 問い = 1 フォルダ。
用語は [CONTEXT.md](../../CONTEXT.md)、パッケージとの分離の規則は [code/README.md](../README.md)。

```text
code/experiments/
└── <YYYYMMDD>_<名前>/     # 日付は開始日。名前は英小文字と - （例: 20261010_second-pole）
    ├── README.md          # 問い・手順・結論
    ├── report.md          # 観察（図は results/ の PDF/PNG を相対パスで参照）
    ├── scripts/           # 実行スクリプト。パッケージを import する
    ├── tests/             # この実験だけの検査
    └── results/           # 出力。全量 git-annex（.gitattributes）。GitHub には symlink のみが載る
```

- パッケージ（`src/`）のみを import する。他の実験の `scripts/` もレガシーも import しない（`sys.path` で辿らない）
- 2 つ目の実験が同じコードを必要とした時点で、そのコードをパッケージへ昇格させる
- 要件・設計の文書は実験フォルダに置かず、`docs/issues/` の主題ファイルと `docs/adr/` で管理する
- `prototype` スキルの成果物（使い捨ての HTML・スクリプト）もここに置く
- 論文・ノートが引用する図は、実験の `results/` から各ノートの `fig/` へ複製する（ノート側は追跡される）
