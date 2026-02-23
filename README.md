# claude-code-wp-skill

Claude Code から SSH + WP-CLI 経由で WordPress を操作するスキルテンプレートです。

A Claude Code skill template for managing WordPress via SSH + WP-CLI.

## 機能 / Features

- `/wp list` — 記事一覧を表示
- `/wp new` — 新規下書き投稿（Markdown → Gutenberg ブロック自動変換）
- `/wp edit <ID>` — 既存記事を編集
- `/wp pages` — 固定ページ一覧
- `/wp page edit <ID>` — 固定ページを編集
- `/wp tags` — タグ一覧
- `/wp publish <ID>` — 下書きを公開

## 前提条件 / Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- SSH でサーバーにパスワードなしで接続できること（`~/.ssh/config` に設定済み）
- サーバーに [WP-CLI](https://wp-cli.org/) がインストール済み

## インストール / Installation

```bash
# スキルディレクトリを作成
mkdir -p ~/.claude/skills/wp

# SKILL.md をコピー
cp SKILL.md ~/.claude/skills/wp/SKILL.md
```

## 設定 / Configuration

`SKILL.md` 内のプレースホルダーを自分の環境に合わせて書き換えてください。

| プレースホルダー | 説明 | 例 |
|---|---|---|
| `<YOUR_SSH_HOST>` | SSH ホスト名（`~/.ssh/config` の Host） | `myserver` |
| `<YOUR_WP_PATH>` | サーバー上の WordPress ルートパス | `/home/user/example.com/public_html` |
| `<YOUR_DOMAIN>` | サイトのドメイン | `example.com` |
| `<YOUR_LOCAL_DRAFTS_PATH>` | ローカルの原稿フォルダ（任意） | `drafts/` |

カテゴリ ID テーブルも自分のサイトに合わせて更新してください。以下のコマンドで確認できます:

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> term list category --fields=term_id,name --format=table"
```

## 使い方 / Usage

Claude Code のチャットで以下のように入力します:

```
/wp list          # 記事一覧
/wp new           # 新規投稿（対話形式で内容を入力）
/wp edit 123      # ID:123 の記事を編集
/wp publish 123   # ID:123 を公開
/wp tags          # タグ一覧
/wp pages         # 固定ページ一覧
/wp page edit 45  # ID:45 の固定ページを編集
```

## License

[MIT](LICENSE)
