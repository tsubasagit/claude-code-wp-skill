---
name: wp
description: "WordPress の記事投稿・編集・固定ページ操作スキル。SSH + WP-CLI で操作する。"
argument-hint: "[new|edit ID|list|pages|page edit ID|tags|publish ID|media FILE]"
disable-model-invocation: false
---

# WordPress 操作スキル

## 定数

- **SSH ホスト**: `<YOUR_SSH_HOST>`
- **WP パス**: `--path=<YOUR_WP_PATH>`
- **一時ファイル**: `/tmp/wp-claude-*.html`（サーバー側）
- **ローカル原稿**: `<YOUR_LOCAL_DRAFTS_PATH>`

### カテゴリ ID

> **注意**: 以下はサンプル値です。必ず自分のサイトのカテゴリ ID に書き換えてください。

| カテゴリ名 | ID |
|---|---|
| *Blog* | *1* |
| *News* | *2* |
| *Tips* | *3* |

> `ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> term list category --fields=term_id,name --format=table"` で実際の値を確認できます。

### SSH コマンドの基本形

全コマンドで以下の省略形を使う:

```
WP="wp --path=<YOUR_WP_PATH>"
```

実行は `ssh <YOUR_SSH_HOST> "$WP <サブコマンド>"` の形式。

---

## 操作別手順

引数 `$ARGS` をパースし、以下の操作を実行する。

---

### `list` — 記事一覧

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post list --post_type=post --post_status=draft,publish --fields=ID,post_title,post_status,post_date --format=table"
```

結果をテーブル形式でユーザーに表示する。

---

### `tags` — タグ一覧

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> term list post_tag --fields=term_id,name --format=table"
```

---

### `pages` — 固定ページ一覧

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post list --post_type=page --post_status=draft,publish --fields=ID,post_title,post_status --format=table"
```

---

### `new` — 新規下書き投稿

手順:

1. ユーザーに記事の内容を確認する（タイトル、本文、カテゴリ、タグ）
   - 本文が Markdown の場合は Gutenberg ブロック形式（`<!-- wp:paragraph -->` 等）に変換する
   - 見出しは `<!-- wp:heading {"level":N} --><hN>...</hN><!-- /wp:heading -->`
   - 段落は `<!-- wp:paragraph --><p>...</p><!-- /wp:paragraph -->`
   - リストは `<!-- wp:list --><ul><li>...</li></ul><!-- /wp:list -->`
2. 変換した HTML を一時ファイルに書き出す（ローカル）
3. SCP でサーバーの `/tmp/wp-claude-<timestamp>.html` に転送:
   ```bash
   scp /tmp/wp-claude-<timestamp>.html <YOUR_SSH_HOST>:/tmp/wp-claude-<timestamp>.html
   ```
4. `wp post create` で下書き投稿:
   ```bash
   ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post create /tmp/wp-claude-<timestamp>.html --post_title='<タイトル>' --post_status=draft --post_category=<カテゴリID> --porcelain"
   ```
   `--porcelain` で投稿 ID のみ返る。
5. タグを付与:
   - 既存タグは事前に `wp term list post_tag` で確認
   - `wp post term add <POST_ID> post_tag <タグ名>` で付与（複数回実行）
6. サーバーの一時ファイルを削除:
   ```bash
   ssh <YOUR_SSH_HOST> "rm /tmp/wp-claude-<timestamp>.html"
   ```
7. 結果をユーザーに報告:
   - 投稿 ID
   - 管理画面 URL: `https://<YOUR_DOMAIN>/wp-admin/post.php?post=<ID>&action=edit`

---

### `edit ID` — 既存記事編集

手順:

1. 記事の現在の内容を取得:
   ```bash
   ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post get <ID> --fields=post_title,post_content,post_status --format=json"
   ```
2. タグも取得:
   ```bash
   ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post term list <ID> post_tag --fields=name --format=csv"
   ```
3. 現在の内容をユーザーに表示し、編集指示を受ける
4. 変更内容に応じて更新:
   - **タイトルのみ**: `wp post update <ID> --post_title='<新タイトル>'`
   - **本文更新**: HTML を一時ファイルに書き出し → SCP → `wp post update <ID> /tmp/wp-claude-<timestamp>.html` → 一時ファイル削除
   - **タグ追加**: `wp post term add <ID> post_tag <タグ名>`
   - **タグ削除**: `wp post term remove <ID> post_tag <タグ名>`

---

### `page edit ID` — 固定ページ編集

手順は `edit` と同じ。`wp post get` / `wp post update` は固定ページにも使える（post_type に依存しない）。

---

### `media FILE` — 画像アップロード

手順:

1. ローカルの画像ファイルを SCP でサーバーに転送:
   ```bash
   scp <LOCAL_FILE> <YOUR_SSH_HOST>:/tmp/wp-claude-media-<filename>
   ```
2. `wp media import` でメディアライブラリに登録:
   ```bash
   ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> media import /tmp/wp-claude-media-<filename> --porcelain"
   ```
   `--porcelain` でアタッチメント ID のみ返る。
3. サーバーの一時ファイルを削除:
   ```bash
   ssh <YOUR_SSH_HOST> "rm /tmp/wp-claude-media-<filename>"
   ```
4. アップロードした画像の URL を取得:
   ```bash
   ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post get <ATTACHMENT_ID> --field=guid"
   ```
5. 結果をユーザーに報告:
   - アタッチメント ID
   - 画像 URL
   - 投稿に挿入する場合は `<!-- wp:image {"id":<ATTACHMENT_ID>} --><figure class="wp-block-image"><img src="<URL>" alt="" class="wp-image-<ATTACHMENT_ID>"/></figure><!-- /wp:image -->` の形式を案内

---

### `publish ID` — 下書きを公開

```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post update <ID> --post_status=publish"
```

公開後、URL を返す:
```bash
ssh <YOUR_SSH_HOST> "wp --path=<YOUR_WP_PATH> post get <ID> --field=url"
```

---

## タグのルール

- 既存タグがあればそれを使う（新規作成前に `wp term list post_tag` で確認）
- 新規タグは `wp post term add` で自動作成される
- タグの確認は `/wp tags` で行う

## エラー時の対応

- SSH 接続失敗 → `ssh <YOUR_SSH_HOST> echo ok` で接続テストを提案
- WP-CLI エラー → エラーメッセージをそのままユーザーに表示し、対処を相談
- 投稿 ID が存在しない → `wp post get <ID>` の結果を確認しユーザーに報告
