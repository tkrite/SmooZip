# SecureZip for Mac — Xcode プロジェクト設定ガイド

> 対象: macOS 13.0+, Swift 5.9+, SwiftUI
> 最終更新: 2026-03-02

---

## 概要

このガイドでは、`SecureZip/` ディレクトリ内の Swift ソースコードから
Xcode プロジェクトをゼロから構築する手順を説明します。

```
SecureZip/
├── Package.swift              # SPM 依存関係定義（参照用）
├── SecureZip/                 # アプリケーションソース
│   └── SecureZip/             # Swift ソースファイル群
└── SecureZipTests/            # テストターゲット
```

---

## Step 1: Xcode プロジェクトの作成

1. Xcode を起動し **File > New > Project** を選択
2. **macOS > App** を選択して **Next**
3. 以下の設定を入力：

| 項目 | 値 |
|------|-----|
| Product Name | `SecureZip` |
| Organization Identifier | `com.securezip` （任意のリバースドメイン） |
| Bundle Identifier | `com.securezip.app` |
| Interface | `SwiftUI` |
| Language | `Swift` |
| Storage | `None`（CoreData は手動設定） |

4. 保存先として `SecureZip/` ディレクトリと **同じ階層** を選択

---

## Step 2: ソースファイルの追加

1. Xcode の Project Navigator で **SecureZip ターゲット** を右クリック
   → **Add Files to "SecureZip"...** を選択
2. `SecureZip/SecureZip/` 内の以下のフォルダをまとめて追加：

```
SecureZip/SecureZip/
├── App/
├── Extensions/
├── Infrastructure/
├── Models/
├── Resources/
├── Services/
├── ViewModels/
└── Views/
```

> **注意**: 「Create groups」を選択し、「Copy items if needed」は **チェックしない**

---

## Step 3: Swift Package Manager（SPM）依存関係の追加

**File > Add Package Dependencies...** を開き、以下を順番に追加します。

### 3-1. GoogleSignIn-iOS（OAuth 2.0 認証）

```
https://github.com/google/GoogleSignIn-iOS.git
```

- **Dependency Rule**: Up to Next Major Version → `7.0.0`
- **Add to Target**: `SecureZip`
- 追加するライブラリ: **GoogleSignIn**

### 3-2. GTMAppAuth（OAuth トークン管理・自動リフレッシュ）

```
https://github.com/google/GTMAppAuth.git
```

- **Dependency Rule**: Up to Next Major Version → `4.0.0`
- **Add to Target**: `SecureZip`
- 追加するライブラリ: **GTMAppAuth**

---

## Step 4: libarchive のリンク設定

libarchive は macOS に標準搭載されているため、追加インストール不要です。
リンカーへの指定のみ必要です。

### 4-1. Other Linker Flags の設定

1. Project Navigator でプロジェクトファイルを選択
2. **TARGETS > SecureZip > Build Settings** タブを開く
3. 検索欄に `Other Linker Flags` と入力
4. **Debug・Release 共に** `-larchive` を追加

```
Other Linker Flags: -larchive
```

### 4-2. ブリッジングヘッダーの作成

1. **File > New > File > Header File** を選択
2. ファイル名: `SecureZip-Bridging-Header.h`
3. 保存先: `SecureZip/SecureZip/` （ソースルート直下）
4. 以下の内容を記述：

```c
#ifndef SecureZip_Bridging_Header_h
#define SecureZip_Bridging_Header_h

#import <archive.h>
#import <archive_entry.h>

#endif /* SecureZip_Bridging_Header_h */
```

### 4-3. ブリッジングヘッダーのパスを設定

1. **TARGETS > SecureZip > Build Settings**
2. 検索: `Swift Compiler - General > Objective-C Bridging Header`
3. 値を設定:

```
SecureZip/SecureZip-Bridging-Header.h
```

---

## Step 5: Core Data モデルの作成

### 5-1. データモデルファイルの追加

1. **File > New > File > Data Model** を選択
2. ファイル名: `SecureZip`（`SecureZip.xcdatamodeld` が生成される）
3. **Add to Target: SecureZip** にチェック

### 5-2. エンティティの定義

モデルエディタで以下の 3 エンティティを作成します。

#### SendHistoryEntity

| Attribute | Type | Optional |
|-----------|------|----------|
| `id` | UUID | No |
| `recipientId` | UUID | No |
| `recipientEmail` | String | No |
| `fileName` | String | No |
| `originalFileNames` | String | No |
| `fileSize` | Integer 64 | No |
| `format` | String | No |
| `isEncrypted` | Boolean | No |
| `sentAt` | Date | **Yes** |
| `expiresAt` | Date | **Yes** |
| `status` | String | No |
| `createdAt` | Date | No |

#### RecipientEntity

| Attribute | Type | Optional |
|-----------|------|----------|
| `id` | UUID | No |
| `email` | String | No |
| `name` | String | **Yes** |
| `createdAt` | Date | No |
| `updatedAt` | Date | No |

#### AppSettingsEntity

| Attribute | Type | Optional |
|-----------|------|----------|
| `id` | UUID | No |
| `key` | String | No |
| `value` | String | No |
| `updatedAt` | Date | No |

> **補足**: `CoreDataStack.swift` にプログラム定義のフォールバックが実装されているため、
> `.xcdatamodeld` が存在しない場合はインメモリストアで自動代替されます。

---

## Step 6: Entitlements（権限）の設定

既存の `SecureZip.entitlements` ファイルをプロジェクトに追加し、
Build Settings で参照を設定します。

### 6-1. ファイルの確認

`SecureZip/SecureZip/SecureZip.entitlements` に以下の権限が定義されています：

| 権限キー | 値 | 用途 |
|---------|-----|------|
| `com.apple.security.app-sandbox` | `true` | App Sandbox 有効化 |
| `com.apple.security.network.client` | `true` | Gmail API 通信 |
| `com.apple.security.files.user-selected.read-write` | `true` | ユーザー選択ファイルの読み書き |
| `com.apple.security.files.downloads.read-write` | `true` | ダウンロードフォルダへの解凍出力 |

### 6-2. Build Settings への設定

1. **TARGETS > SecureZip > Build Settings**
2. 検索: `Code Signing Entitlements`
3. 値を設定:

```
SecureZip/SecureZip.entitlements
```

---

## Step 7: URL Scheme の設定（OAuth コールバック用）

Google OAuth 認証後のリダイレクトを受け取るために URL Scheme を登録します。

1. **TARGETS > SecureZip > Info** タブを開く
2. **URL Types** セクションで **+** をクリック
3. 以下を入力：

| 項目 | 値 |
|------|-----|
| Identifier | `com.securezip.app` |
| URL Schemes | `com.securezip.app` （Google Cloud Console で設定した値） |
| Role | `Editor` |

> **注意**: Google Cloud Console での OAuth クライアント ID 設定時に
> macOS アプリ用のリダイレクト URI として `com.securezip.app:/oauth2redirect` を追加してください。

---

## Step 8: Deployment Target の確認

1. **PROJECT > SecureZip > Info** タブ
2. **macOS Deployment Target**: `13.0`

---

## Step 9: ビルド設定の最終確認

| Build Setting | 設定値 |
|--------------|--------|
| Swift Language Version | `Swift 5.9` |
| macOS Deployment Target | `13.0` |
| Other Linker Flags | `-larchive` |
| Objective-C Bridging Header | `SecureZip/SecureZip-Bridging-Header.h` |
| Code Signing Entitlements | `SecureZip/SecureZip.entitlements` |

---

## Step 10: 初回ビルドの確認

`⌘ + B` でビルドを実行し、以下のエラーがないことを確認します。

### よくあるエラーと対処

| エラー | 原因 | 対処 |
|--------|------|------|
| `archive.h not found` | ブリッジングヘッダーのパスが誤り | Step 4-3 を再確認 |
| `Undefined symbol: _archive_write_new` | `-larchive` が未設定 | Step 4-1 を再確認 |
| `Cannot find type 'CompressionFormat' in scope` | モジュールのスコープ問題 | ファイルの **Target Membership** を確認 |
| `'Observable()' is only available in macOS 14.0+` | Deployment Target が 13.0 | 正常（macOS 13 では `@Observable` は非推奨警告だが動作） |
| `Module 'GoogleSignIn' not found` | SPM パッケージ未解決 | **File > Packages > Resolve Package Versions** |

---

## Phase 2 での追加設定（予定）

以下は現時点で未実装のため、Phase 2 実装時に追加が必要です。

### Google Sign-In SDK の OAuth 実装

`GmailService.authenticate()` に以下を実装：

```swift
// TODO: Phase 2 で実装
// 1. GIDSignIn.sharedInstance.signIn(withPresenting:) を呼び出す
// 2. アクセストークンを Keychain に保存
// 3. isAuthenticated = true をセット
```

Google Cloud Console での設定：
- プロジェクトを作成し OAuth クライアント ID（macOS アプリ用）を取得
- `gmail.send` スコープを有効化
- クライアント ID を `GoogleService-Info.plist` に記載してプロジェクトに追加

### libarchive C API による AES-256 暗号化（Phase 2）

現在は `/usr/bin/zip -e`（ZipCrypto）を使用。
AES-256 対応のためには `LibArchiveWrapper.swift` にある C API 実装が必要です。
ブリッジングヘッダー設定（Step 4-2）完了後、実装を切り替えてください。
