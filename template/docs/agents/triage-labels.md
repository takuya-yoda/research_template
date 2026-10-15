# Triage ラベル

スキルは 5 つの triage role で語る。この表は、その role をこのリポジトリの issue tracker で使う文字列へ対応づける。主題ファイルとチケットファイルの `Status:` 行にこの文字列を書く。

| mattpocock/skills での role | このリポジトリでの文字列 | 意味 |
|---|---|---|
| `needs-triage` | `needs-triage` | 評価待ち |
| `needs-info` | `needs-info` | 起票者からの追加情報待ち |
| `ready-for-agent` | `ready-for-agent` | 仕様が確定し、エージェントが単独で着手できる |
| `ready-for-human` | `ready-for-human` | 人による実装が必要 |
| `wontfix` | `wontfix` | 対応しない |

主題ファイルの段階との対応と、完了を表す `closed` は `issue-tracker.md` に定める。

スキルが role に言及したとき（例:「AFK-ready のラベルを付ける」）は、この表の対応する文字列を使う。
