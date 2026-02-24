# claude-code-wp-skill

Claude Code から SSH + WP-CLI 経由で WordPress を操作するスキルテンプレートです。

A Claude Code skill template for managing WordPress via SSH + WP-CLI.

## Architecture / アーキテクチャ

```
┌─────────────────┐      SSH       ┌──────────────────────┐
│  Claude Code     │ ──────────────▶│  WordPress Server    │
│  (local)         │                │                      │
│  ┌─────────┐    │   SCP (files)  │  ┌──────────┐       │
│  │ SKILL.md│────│───────────────▶│  │  WP-CLI  │       │
│  └─────────┘    │                │  └────┬─────┘       │
│                  │                │       │              │
│  /wp <command>   │                │       ▼              │
│                  │                │  ┌──────────┐       │
└─────────────────┘                │  │WordPress │       │
                                    │  │  DB      │       │
                                    │  └──────────┘       │
                                    └──────────────────────┘
```

## Commands / コマンド一覧

| Command | Description / 説明 |
|---|---|
| `/wp list` | 記事一覧を表示 / List posts |
| `/wp new` | 新規下書き投稿（Markdown → Gutenberg 自動変換） / Create draft post |
| `/wp edit <ID>` | 既存記事を編集 / Edit existing post |
| `/wp pages` | 固定ページ一覧 / List pages |
| `/wp page edit <ID>` | 固定ページを編集 / Edit page |
| `/wp tags` | タグ一覧 / List tags |
| `/wp publish <ID>` | 下書きを公開 / Publish draft |
| `/wp media <FILE>` | 画像をアップロード / Upload image to media library |

## Prerequisites / 前提条件

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) がインストール済み
- SSH でサーバーにパスワードなしで接続できること（`~/.ssh/config` に設定済み）
- サーバーに [WP-CLI](https://wp-cli.org/) がインストール済み

## Installation / インストール

### Quick Install / クイックインストール

```bash
git clone https://github.com/tsubasagit/claude-code-wp-skill.git
cd claude-code-wp-skill
bash install.sh
```

### Manual Install / 手動インストール

```bash
mkdir -p ~/.claude/skills/wp
cp SKILL.md ~/.claude/skills/wp/SKILL.md
```

## Configuration / 設定

`~/.claude/skills/wp/SKILL.md` 内のプレースホルダーを自分の環境に合わせて書き換えてください。

Edit the placeholders in `~/.claude/skills/wp/SKILL.md` to match your environment.

| Placeholder | Description / 説明 | Example / 例 |
|---|---|---|
| `<YOUR_SSH_HOST>` | SSH ホスト名（`~/.ssh/config` の Host） | `myserver` |
| `<YOUR_WP_PATH>` | サーバー上の WordPress ルートパス | `/home/user/example.com/public_html` |
| `<YOUR_DOMAIN>` | サイトのドメイン | `example.com` |
| `<YOUR_LOCAL_DRAFTS_PATH>` | ローカルの原稿フォルダ（任意） | `drafts/` |

カテゴリ ID テーブルも自分のサイトに合わせて更新してください:

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> term list category --fields=term_id,name --format=table"
```

## Usage / 使い方

Claude Code のチャットで以下のように入力します:

```
/wp list          # 記事一覧
/wp new           # 新規投稿（対話形式で内容を入力）
/wp edit 123      # ID:123 の記事を編集
/wp publish 123   # ID:123 を公開
/wp tags          # タグ一覧
/wp pages         # 固定ページ一覧
/wp page edit 45  # ID:45 の固定ページを編集
/wp media photo.jpg  # 画像をアップロード
```

## Security / セキュリティ

### Configured SKILL.md / 設定済み SKILL.md の取り扱い

`SKILL.md` を自分の環境に合わせて編集した後は、その内容に SSH ホスト名やサーバーパスが含まれます。**設定済みの SKILL.md を公開リポジトリにコミットしないでください。**

After configuring `SKILL.md` with your environment details, it will contain SSH hostnames and server paths. **Do not commit the configured SKILL.md to a public repository.**

### SSH Key Management / SSH 鍵管理

- SSH 鍵にはパスフレーズを設定し、`ssh-agent` で管理することを推奨します
- サーバー側では WP-CLI 実行に必要な最小限の権限のみを持つユーザーを使用してください
- `~/.ssh/config` で接続先ごとに使用する鍵ファイルを明示的に指定してください

## Contributing / コントリビュート

Issue や Pull Request を歓迎します。

Issues and Pull Requests are welcome.

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

[MIT](LICENSE)
