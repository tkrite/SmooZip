# 開発ログ - 2026-03-11

## 📋 基本情報
- **日付**: 2026-03-11
- **開発者**: Claude Code
- **ブランチ**: `master`
- **関連Issue**: -
- **プロジェクトフェーズ**: Phase 5（App Store 申請準備）

## 🎯 本日の開発目標
### 計画タスク
- [x] コードレビュー全体実施（Apple 申請向け指摘修正） - 優先度: 高
- [x] ローカライズ対応（PasswordStrength / SendStatus） - 優先度: 高
- [x] プライバシーポリシー更新（GDPR / CCPA / COPPA 対応） - 優先度: 高
- [x] App Store 申請残タスク整理 - 優先度: 中

### 完了条件
- 全修正後にビルドが通ること
- 送信機能の実機動作が確認できること
- プライバシーポリシーが各規制要件（GDPR / CCPA / COPPA）を充足すること

## 📝 実装内容

### 1. コードレビュー指摘修正（Apple 申請向け 10件）

#### 実装概要
```
前回（2026-03-06）のコードレビューに続き、Apple 審査・品質・セキュリティ観点での
追加指摘 10件を修正。スキップした 2件は影響範囲が大きく、意図的に見送り。
```

#### 変更内容

##### Critical / High 優先度
| # | 対象ファイル | 修正内容 |
|---|-------------|---------|
| C-1 | `GmailService.swift` | `sendWithSeparatePassword` にパスワード空文字ガード追加（`separatePassword && !password.isEmpty`） |
| C-2+H-7 | `LibArchiveWrapper.swift` | 解凍時 `archive_write_data` 戻り値チェック追加 + `size_t(n)` 型キャスト明示化 |
| C-3 | `SendViewModel.swift` | 一時ファイル名に `UUID().uuidString` を追加（同名ファイル競合防止） |
| H-1 | `CompressViewModel.swift` | `startAccessingSecurityScopedResource()` 戻り値チェック・失敗時エラー表示 |
| H-1 | `DecompressViewModel.swift` | 同上、`guard` で早期リターン |
| H-1 | `SendViewModel.swift` | 同上、`SecureZipError.fileAccessDenied` をスロー |
| H-3 | `CoreDataStack.swift` | `isUsingFallbackStore: Bool` フラグ追加、フォールバック時にセット |

##### Medium 優先度
| # | 対象ファイル | 修正内容 |
|---|-------------|---------|
| M-3 | `PasswordService.swift` | `SecRandomCopyBytes` 失敗時フォールバックの `!` 強制アンラップを `if let` に変更 |
| M-5 | `AutoDeleteService.swift` | 起動時チェックの `try?` を `do/catch + #if DEBUG print` に変更 |
| M-6 | `GmailAPIClient.swift` | `gmailSendEndpoint` static 定数を定義、init の `!` アンラップ除去 |

##### スキップした修正
| # | 対象 | スキップ理由 |
|---|------|------------|
| H-4 | `keyWindow` 置き換え | OAuth フローへの影響が高いためスキップ |
| H-5 | 並行削除 | CoreData コンテキスト競合リスクのためスキップ |

#### 変更ファイル
- `SecureZip/SecureZip/Services/GmailService.swift` - パスワード空文字ガード追加
- `SecureZip/SecureZip/Infrastructure/LibArchiveWrapper.swift` - 戻り値チェック・型キャスト明示化
- `SecureZip/SecureZip/ViewModels/SendViewModel.swift` - UUID 一時ファイル名・Security-scoped URL ガード・fileAccessDenied スロー
- `SecureZip/SecureZip/ViewModels/CompressViewModel.swift` - Security-scoped URL 戻り値チェック・エラー表示
- `SecureZip/SecureZip/ViewModels/DecompressViewModel.swift` - Security-scoped URL guard 早期リターン
- `SecureZip/SecureZip/Infrastructure/CoreDataStack.swift` - isUsingFallbackStore フラグ追加
- `SecureZip/SecureZip/Services/PasswordService.swift` - if let に変更（強制アンラップ除去）
- `SecureZip/SecureZip/Services/AutoDeleteService.swift` - do/catch + DEBUG print に変更
- `SecureZip/SecureZip/Infrastructure/GmailAPIClient.swift` - static 定数定義・! アンラップ除去

---

### 2. ローカライズ対応（PasswordStrength / SendStatus）

#### 実装概要
```
PasswordStrength.displayName と SendStatus.displayName がハードコードされた日本語文字列を
返していたため、NSLocalizedString 化して en/ja の Localizable.strings に翻訳を追加。
キャンセル済みステータスを新規キーとして定義。
```

#### 変更内容
- **L-4** `PasswordStrength.swift` - `displayName` を `NSLocalizedString` 化
- `SendStatus.swift` - `displayName` を `NSLocalizedString` 化（`キャンセル済み` を新規キーで追加）
- `en.lproj/Localizable.strings` - パスワード強度 4件・送付ステータス 5件を追加
- `ja.lproj/Localizable.strings` - 同上

#### 変更ファイル
- `SecureZip/SecureZip/Models/PasswordStrength.swift` - NSLocalizedString 化
- `SecureZip/SecureZip/Models/SendStatus.swift` - NSLocalizedString 化・キャンセル済みキー追加
- `SecureZip/SecureZip/Resources/en.lproj/Localizable.strings` - 9件追加
- `SecureZip/SecureZip/Resources/ja.lproj/Localizable.strings` - 9件追加

---

### 3. プライバシーポリシー更新（GDPR / CCPA / COPPA 対応）

#### 実装概要
```
Documents/index.html のプライバシーポリシーを大幅改訂。
EU（GDPR）・米国カリフォルニア州（CCPA）・児童オンラインプライバシー保護法（COPPA）
の各規制要件を充足するよう記述を追加・整理。
```

#### 追加・変更内容
| 項目 | 対応する規制 |
|------|------------|
| データ管理者連絡先（info@tkrite.com）追加 | GDPR Art.13 |
| 収集情報の法的根拠テーブル追加 | GDPR Art.6 |
| データ保持期間の明記（デフォルト30日・アンインストール時） | GDPR Art.13(2)(a) |
| Google へのデータ送信の明示（Gmail API 経由） | GDPR Art.13(1)(e) |
| 「個人情報を販売しない」明示的宣言 | CCPA §1798.120 |
| データ主体の権利セクション追加（アクセス・削除・訂正・携帯性・反対） | GDPR Art.15〜22 + CCPA |
| EU 監督機関への苦情申立権 | GDPR Art.13(2)(d) |
| COPPA 対応：保護者連絡先・対応手順 | COPPA |
| セキュリティ対策概要（AES-256・Keychain・App Sandbox） | 任意開示 |
| ポリシー変更の通知方法追記 | CalOPPA §22577 |

#### 変更ファイル
- `Documents/index.html` - プライバシーポリシー全体改訂

---

### 4. App Store 申請残タスク整理

#### 実装概要
```
本日時点での申請残タスクを整理し、翌日以降の対応順序を確定。
GitHub Organization 移管を翌日対応とし、移管後に Privacy Policy URL の
各コンソール設定を行う手順を策定。
```

#### 残タスク整理結果
| タスク | 担当 | 予定日 |
|-------|------|-------|
| GitHub リポジトリ Organization（tkrite）移管 | 担当者 | 2026-03-12 |
| App Store Connect の Privacy Policy URL 更新 | 担当者 | 移管後 |
| Google Cloud Console の Privacy Policy URL 更新 | 担当者 | 移管後 |
| EAR 申告 | 担当者 | 未定 |
| Google OAuth 本番審査申請 | 担当者 | 未定 |
| コード署名確認（Automatic Signing / Team ID） | 担当者 | 未定 |
| TestFlight 配布設定 | 担当者 | 未定 |

## 🧪 テスト実施

### 動作確認
| 確認項目 | 結果 | 備考 |
|---------|------|------|
| ビルド成功 | ✅ | 全修正後クリーンビルド通過 |
| 送信機能（実機動作） | ✅ | ファイル送信・パスワードメール送信確認 |
| ローカライズ（英語表示） | ✅ | PasswordStrength / SendStatus 英語表示確認 |
| Security-scoped URL ガード | ✅ | アクセス拒否時に適切なエラー表示 |

## 🐛 発生した問題と解決

本セッションでは新規バグは発生せず。スキップした修正（H-4 / H-5）については以下の理由で意図的に見送り。

### 問題1（対応保留）: keyWindow 置き換え（H-4）
**状態**: 保留

**理由**:
- `keyWindow` は macOS 向け NSWindow の概念で置き換え先 API の選定に調査が必要
- OAuth フローの継続処理に絡んでいるため、誤った修正で認証が動作しなくなるリスクが高い
- App Store 申請期限を優先し、次フェーズで対応予定

### 問題2（対応保留）: CoreData 並行削除（H-5）
**状態**: 保留

**理由**:
- 複数 context が同一 NSManagedObject を削除する競合シナリオの再現が困難
- 誤ったコンテキスト切り替えによるデータ破損リスクを避けるため、保留

## 💡 技術的発見・学習

### ベストプラクティス
- `archive_write_data` の戻り値は `ssize_t` 型で、負値がエラーを示す。書き込みループでは必ずチェックが必要
- `size_t` と `Int` の暗黙変換は Swift では行われないため、`size_t(n)` の明示キャストが安全
- `SecRandomCopyBytes` はシステムの CSPRNG が枯渇した場合に失敗する可能性があるため、`if let` でのフォールバック処理が望ましい
- `try?` でエラーを握り潰すと Debug 時の診断が困難になるため、`#if DEBUG` ブロックでのログ出力を組み合わせるべき

### 規制対応
- GDPR では「法的根拠（Art.6）」の明示が必須。正当な利益・契約履行・同意の区別を明確に記載すること
- CCPA では「個人情報の販売を行わない」旨を明示的に宣言することで、オプトアウト権の付与義務を回避できる
- COPPA では 13歳未満への意図的なサービス提供の有無を明示し、保護者の問い合わせ先を記載する必要がある

## 📊 進捗状況

### 本日の成果
- ✅ 完了: コードレビュー指摘修正 10件（スキップ 2件は保留）
- ✅ 完了: ローカライズ対応（PasswordStrength / SendStatus）
- ✅ 完了: プライバシーポリシー大幅改訂（GDPR / CCPA / COPPA 対応）
- ✅ 完了: 申請残タスク整理
- 📋 翌日対応: GitHub Organization 移管 / Privacy Policy URL 各コンソール反映

### 全体進捗
```
機能実装:       [██████████] 100%
コード品質:     [█████████░]  95%（H-4/H-5 保留）
ローカライズ:   [█████████░]  95%
App Store 提出: [████░░░░░░]  40%（担当者作業待ち）
```

## 🔄 コミット履歴

```
# 本セッションの主要変更
- fix(gmail): sendWithSeparatePassword にパスワード空文字ガード追加
- fix(libarchive): archive_write_data 戻り値チェック・size_t 型キャスト明示化
- fix(send): 一時ファイル名に UUID 追加（競合防止）
- fix(compress): startAccessingSecurityScopedResource 戻り値チェック追加
- fix(decompress): startAccessingSecurityScopedResource guard 早期リターン
- fix(coredata): isUsingFallbackStore フラグ追加
- fix(password-service): SecRandomCopyBytes フォールバックを if let に変更
- fix(auto-delete): 起動時チェックを do/catch + DEBUG print に変更
- fix(gmail-api): gmailSendEndpoint static 定数定義・! アンラップ除去
- feat(l10n): PasswordStrength / SendStatus を NSLocalizedString 化
- feat(l10n): en/ja Localizable.strings にパスワード強度・ステータス翻訳追加
- docs(privacy): プライバシーポリシーを GDPR/CCPA/COPPA 対応に改訂
```

## 🔮 明日の予定

### 優先タスク
1. GitHub リポジトリを Organization（tkrite）に移管
2. App Store Connect の Privacy Policy URL を移管後の URL に更新
3. Google Cloud Console の Privacy Policy URL を更新
4. EAR 申告対応

### 懸念事項
- GitHub Organization 移管後、既存の GitHub Pages URL が変わる可能性があるため、移管前後で URL を確認すること
- Google Cloud Console の OAuth 同意画面に設定した Privacy Policy URL も忘れずに更新すること

### 必要なサポート
- 未記載（担当者との調整待ち）

## 📌 メモ・備考

### プライバシーポリシー URL について
- 現在 `Documents/index.html` としてリポジトリ内に存在
- GitHub Organization 移管後、GitHub Pages の URL が確定してから App Store Connect・Google Cloud Console に設定
- URL 変更が生じた場合は、アプリ内のリンク（SettingsView 等）も合わせて確認すること

### スキップ修正の今後の方針
- **H-4（keyWindow 置き換え）**: OAuth フローの動作を保護しつつ、`NSApplication.shared.mainWindow` 等への安全な移行方法を次フェーズで調査
- **H-5（並行削除）**: CoreData の `performAndWait` を用いたシリアル処理パターンへの移行を次フェーズで検討

## 📈 メトリクス

| 指標 | 値 |
|------|-----|
| 修正件数 | 10件（指摘10エントリ対応・スキップ 2件除く） |
| ローカライズ追加キー数 | 9件（en/ja 各） |
| 変更ファイル数 | 14ファイル |
| 生産性 | 高 |

## 🏷️ タグ
`#development` `#appstore-prep` `#code-review` `#swift` `#macos` `#security` `#l10n` `#privacy` `#gdpr` `#ccpa` `#2026-03-11`

---
*作成: 2026-03-11 JST*
*最終更新: 2026-03-11 JST*
