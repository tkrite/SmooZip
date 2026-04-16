# 📱 App Site Template for Jekyll

Apple App Store / Google Play Store 申請に必要なサポートサイトの Jekyll テンプレートです。  
GitHub Pages でホスティングすることを前提としています。

## 📋 含まれるページ

| ページ | パス | Apple 用途 | Google 用途 |
|---|---|---|---|
| **トップページ** | `/` | マーケティングURL | アプリケーションのホームページ |
| **サポート** | `/support/` | サポートURL | — |
| **プライバシーポリシー** | `/privacy-policy/` | プライバシーポリシーURL | プライバシーポリシー |
| **利用規約** | `/terms/` | — | 利用規約 |
| **ユーザープライバシー選択** | `/user-privacy-choices/` | ユーザープライバシー選択URL (任意) | — |

## 🚀 セットアップ

### 1. リポジトリ作成

```bash
# 新しいリポジトリにこのテンプレートをコピー
git clone <this-repo> my-app-site
cd my-app-site
rm -rf .git
git init
git remote add origin git@github.com:<username>/<repo-name>.git
```

### 2. `_config.yml` を編集

最低限、以下の項目を変更してください：

```yaml
title: "あなたのアプリ名"
description: "アプリの説明"
url: "https://yourusername.github.io"
baseurl: "/your-repo-name"

app:
  name: "あなたのアプリ名"
  tagline: "キャッチコピー"
  app_store_url: "https://apps.apple.com/app/idXXXXXXXXX"
  play_store_url: "https://play.google.com/store/apps/details?id=com.example.app"
  support_email: "support@example.com"
  support_videos:
    - title: "使い方"
      youtube_id: "実際のYouTube動画ID"

developer:
  name: "開発者名"
  email: "contact@example.com"
```

### 3. アプリアイコンを配置

```
assets/images/app-icon.png    # 512x512 推奨
assets/images/screenshot.png  # スクリーンショット（任意）
```

### 4. GitHub Pages で公開

```bash
git add .
git commit -m "Initial setup"
git push -u origin main
```

GitHub リポジトリの **Settings > Pages** で：
- Source: **GitHub Actions** を選択

### 5. ストア審査に URL を登録

デプロイ後、以下の URL をストア審査に使用できます：

**Apple App Store Connect:**

| 項目 | URL |
|---|---|
| マーケティングURL | `https://<user>.github.io/<repo>/` |
| サポートURL | `https://<user>.github.io/<repo>/support/` |
| プライバシーポリシーURL | `https://<user>.github.io/<repo>/privacy-policy/` |
| ユーザープライバシー選択URL | `https://<user>.github.io/<repo>/user-privacy-choices/` |

**Google Play Console:**

| 項目 | URL |
|---|---|
| アプリケーションのホームページ | `https://<user>.github.io/<repo>/` |
| プライバシーポリシー | `https://<user>.github.io/<repo>/privacy-policy/` |
| 利用規約 | `https://<user>.github.io/<repo>/terms/` |

## 🎨 カスタマイズ

### テーマカラーの変更

`assets/css/style.css` の CSS 変数を変更：

```css
:root {
  --color-primary: #0071e3;       /* メインカラー */
  --color-primary-dark: #0059b3;  /* ホバー時 */
  --color-primary-light: #e8f4fd; /* 背景アクセント */
}
```

### サポート動画の追加

`_config.yml` の `support_videos` に YouTube 動画を追加：

```yaml
support_videos:
  - title: "動画タイトル"
    youtube_id: "YouTube動画のID"
    description: "動画の説明"
```

### 機能一覧の編集

`_config.yml` の `features` セクションを編集：

```yaml
features:
  - icon: "⚡"
    title: "高速処理"
    description: "説明文"
```

## 🏗 ローカルプレビュー

```bash
bundle install
bundle exec jekyll serve
# http://localhost:4000/<baseurl>/ で確認
```

## 📁 ファイル構成

```
.
├── _config.yml              # ★ メイン設定ファイル（ここを編集）
├── _layouts/
│   ├── default.html         # ベースレイアウト
│   └── page.html            # コンテンツページ用
├── _includes/
│   ├── header.html          # ヘッダー・ナビゲーション
│   └── footer.html          # フッター（サイトマップ含む）
├── assets/
│   ├── css/style.css        # スタイルシート
│   └── images/              # アプリアイコン等
├── index.html               # トップページ
├── support.html             # サポートページ
├── privacy-policy.md        # プライバシーポリシー
├── terms.md                 # 利用規約
├── user-privacy-choices.md  # ユーザープライバシー選択
├── .github/workflows/
│   └── jekyll.yml           # GitHub Actions デプロイ設定
├── Gemfile
└── README.md
```

## ⚠️ 注意事項

- プライバシーポリシー・利用規約の内容はテンプレートです。アプリの仕様に合わせて必ず内容を確認・修正してください。
- 法的文書として使用する場合は、必要に応じて専門家にご相談ください。
- `baseurl` の設定を忘れると CSS やリンクが壊れるのでご注意ください。
