# 開発ログ - 2026-03-05

## 基本情報
- **日付**: 2026-03-05
- **開発者**: Claude Code
- **ブランチ**: `master`
- **関連Issue**: 未記載（チケット番号なし）
- **プロジェクトフェーズ**: テスト

## 本日の開発目標
### 計画タスク
- [x] テストターゲットのビルド設定を macOS 向けに修正 - 優先度: 高
- [x] エンタイトルメント修正（Hardened Runtime 対応） - 優先度: 高
- [x] デプロイメントターゲットを現実的なバージョンに更新 - 優先度: 中
- [x] 全テストスイートの通過確認 - 優先度: 高

### 完了条件
- 全テストスイートが PASSED となること
- ビルド警告がゼロであること

## 実装内容

### 1. テストターゲット設定の修正（project.pbxproj）
**作業時間**: 未記載

#### 実装概要
```
Xcode が自動生成したテストターゲットのビルド設定が iOS 向けになっていたため、
macOS 向けに修正した。条件付きキーの正規化、TestTargetID の追加、
テストプランの有効化、Bridging Header 対応の HEADER_SEARCH_PATHS 追加を実施。
```

#### 技術的詳細

**修正1: SDK・デプロイメントターゲット**
```
- SDKROOT = iphoneos → macosx
- IPHONEOS_DEPLOYMENT_TARGET = 26.2 → 削除
- MACOSX_DEPLOYMENT_TARGET を追加（最終的に 15.0）
- TARGETED_DEVICE_FAMILY = "1,2" → 削除
- SUPPORTED_PLATFORMS = macosx を追加
- iOS 専用フラグ（SWIFT_APPROACHABLE_CONCURRENCY 等）を削除
```

**修正2: BUNDLE_LOADER / TEST_HOST の正規化**
```
- "BUNDLE_LOADER[arch=*]" → BUNDLE_LOADER（条件付きキーを削除）
- "TEST_HOST[sdk=*]" → TEST_HOST（条件付きキーを削除）
```

**修正3: TargetAttributes に TestTargetID を追加**
```
Xcode がテストターゲットをアプリと正しく関連付けるために必要。
TargetAttributes セクションに TestTargetID を明示的に追加。
```

**修正4: テストプランの有効化（SecureZipTests.xctestplan）**
```json
// 修正前
"enabled": false

// 修正後
"enabled": true
```

**修正5: HEADER_SEARCH_PATHS をテストターゲットに追加**
```
@testable import SecureZip 時に Bridging Header の依存スキャンが走るため、
libarchive のインクルードパスをテストターゲットにも追加。
追加パス: /opt/homebrew/opt/libarchive/include
```

#### 変更ファイル
- `SecureZip/SecureZip.xcodeproj/project.pbxproj` - テストターゲットのビルド設定を iOS から macOS 向けに全面修正
- `SecureZip/SecureZip.xcodeproj/xcshareddata/xcschemes/SecureZipTests.xctestplan` - テストを有効化（`enabled: false → true`）

---

### 2. エンタイトルメント修正（SecureZip.entitlements）
**作業時間**: 未記載

#### 実装概要
```
Homebrew 製 libarchive.13.dylib の Team ID がアプリと異なるため、
Hardened Runtime がライブラリのロードをブロックしていた。
ライブラリ検証を無効化するエンタイトルメントを追加して解消。
```

#### 技術的詳細
```xml
<!-- 追加したエンタイトルメント -->
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

**背景**: Homebrew でインストールされた `libarchive.13.dylib` はサードパーティ署名であり、
アプリの Team ID と一致しない。Hardened Runtime のデフォルト設定では
Team ID が異なる dylib のロードがブロックされるため、ライブラリ検証の無効化が必要。

#### 変更ファイル
- `SecureZip/SecureZip/SecureZip.entitlements` - `com.apple.security.cs.disable-library-validation = true` を追加

---

### 3. デプロイメントターゲットを 15.0 に変更
**作業時間**: 未記載

#### 実装概要
```
アプリターゲット・テストターゲットのデプロイメントターゲットを
macOS 13.0 から 15.0 に引き上げた。
```

#### 変更理由
1. **libarchive 互換性**: Homebrew の libarchive 3.8.1 が macOS 15.0 向けにビルドされており、13.0 ターゲットではクラッシュしていた
2. **XCTest 要件**: `libXCTestSwiftSupport` が macOS 14.0 以降を要求する
3. **ユーザー分布**: 2026 年時点で macOS 13 ユーザーは極めて少数であり、現実的な変更

#### 変更箇所
```
- アプリターゲット（Debug）:  MACOSX_DEPLOYMENT_TARGET 13.0 → 15.0
- アプリターゲット（Release）: MACOSX_DEPLOYMENT_TARGET 13.0 → 15.0
- テストターゲット（Debug）:  MACOSX_DEPLOYMENT_TARGET 13.0 → 15.0
- テストターゲット（Release）: MACOSX_DEPLOYMENT_TARGET 13.0 → 15.0
```

#### 変更ファイル
- `SecureZip/SecureZip.xcodeproj/project.pbxproj` - 全ターゲットのデプロイメントターゲットを更新

## テスト実施

### ユニットテスト
- [x] テストケース作成（既存テストスイートを活用）
- [x] テスト実行
- [x] カバレッジ: 未記載（計測結果の記録なし）

### 動作確認
| テストスイート | 結果 | 備考 |
|---|---|---|
| CompressViewModelTests | PASSED | 全件通過 |
| CompressionServiceTests | PASSED | 全件通過 |
| CryptoServiceTests | PASSED | 全件通過 |
| DecompressViewModelTests | PASSED | 全件通過 |
| HistoryServiceTests | PASSED | 全件通過 |
| HistoryViewModelTests | PASSED | 全件通過 |
| PasswordServiceTests | PASSED | 全件通過 |
| SecureZipTests | PASSED | 全件通過 |
| SendViewModelTests | PASSED | 全件通過 |
| SettingsViewModelTests | PASSED | 全件通過 |

**ビルド警告**: なし
**合計テストスイート**: 10 スイート、全 PASSED

## 発生した問題と解決

### 問題1: テストターゲットが iOS SDK を参照している
**発生時刻**: 未記載

**症状**:
```
テストターゲットのビルドが失敗。SDKROOT = iphoneos のため
macOS 向けフレームワークが解決できない状態。
```

**原因**:
- Xcode が新規テストターゲット追加時に iOS 向けのデフォルト設定を生成した

**解決方法**:
```
project.pbxproj を直接編集し、テストターゲットの全ビルド設定を
macOS 向けに書き換え（SDKROOT, SUPPORTED_PLATFORMS, デプロイメントターゲット等）
```

**対応時間**: 未記載

---

### 問題2: Hardened Runtime による libarchive ロードブロック
**状態**: 解決済

**症状**:
```
実行時に libarchive.13.dylib のロードが Hardened Runtime にブロックされクラッシュ
```

**原因**:
- Homebrew 製 dylib の Team ID がアプリと異なる
- Hardened Runtime のデフォルト設定がサードパーティ dylib をブロック

**解決方法**:
```xml
<!-- SecureZip.entitlements に追加 -->
<key>com.apple.security.cs.disable-library-validation</key>
<true/>
```

**対応時間**: 未記載

---

### 問題3: XCTest が macOS 13 ターゲットで動作しない
**状態**: 解決済

**症状**:
```
libXCTestSwiftSupport がロードできず、テスト実行が失敗
```

**原因**:
- `libXCTestSwiftSupport` は macOS 14.0 以降を要求するが、ターゲットが 13.0 だった

**解決方法**:
```
全ターゲットの MACOSX_DEPLOYMENT_TARGET を 13.0 から 15.0 に引き上げ
```

**対応時間**: 未記載

## 技術的発見・学習

### 新しく学んだこと
- Xcode の自動生成テストターゲットは iOS 向けデフォルト設定になるため、macOS アプリでは project.pbxproj を手動修正する必要がある
- `BUNDLE_LOADER` / `TEST_HOST` の条件付きキー形式（`[arch=*]`, `[sdk=*]`）は macOS テストターゲットでは不要であり、シンプルなキー形式に正規化すべき
- Hardened Runtime 環境で Homebrew の dylib を利用する場合は `com.apple.security.cs.disable-library-validation` エンタイトルメントが必要
- `libXCTestSwiftSupport` は macOS 14.0 以降を要求するため、2026 年時点では 15.0 をデプロイメントターゲットとするのが妥当

### ベストプラクティス
- テストターゲット追加後は project.pbxproj の SDK / デプロイメントターゲット設定を必ず確認する
- `HEADER_SEARCH_PATHS` はアプリターゲットだけでなく、`@testable import` を使うテストターゲットにも同一パスを設定する
- `TargetAttributes` の `TestTargetID` を設定することで、Xcode がテストターゲットとアプリを正しく関連付ける

### パフォーマンス改善
- 未記載（本作業はビルド設定修正のためパフォーマンス改善は対象外）

## 進捗状況

### 本日の成果
- 完了: テストターゲット macOS 化（100%）
- 完了: Hardened Runtime 対応（100%）
- 完了: デプロイメントターゲット更新（100%）
- 完了: 全 10 テストスイート PASSED 確認（100%）

### 全体進捗
```
機能実装:    [████████░░] 80%
テスト作成:  [██████████] 100%（全スイート通過）
ドキュメント: [████████░░] 80%
```

## コミット履歴

```bash
# 本日のコミット（関連コミット抜粋）
- test: HistoryViewModel / DecompressViewModel / SettingsViewModel のテスト追加
- test: CryptoServiceTests 修正・SendViewModelTests 拡充
- refactor: 解凍進捗改善・Timer廃止・CryptoService整理
- fix/test: DropZone エラー通知・CoreData テスト基盤・HistoryServiceTests 実装
```

## コードレビュー指摘事項

### レビュアーからの指摘
- 未記載（本作業はビルド設定修正のため、コードレビューの記録なし）

### セルフレビュー
- [x] コーディング規約準拠（設定ファイルのため規約対象外）
- [x] エラーハンドリング（ビルド設定修正のため対象外）
- [x] ログ出力（ビルド設定修正のため対象外）
- [x] コメント記載（設定ファイルのため対象外）

## 明日の予定

### 優先タスク
1. テストカバレッジの計測・記録
2. Gmail OAuth フローの E2E 動作確認
3. 圧縮・解凍の統合テスト追加検討

### 懸念事項
- `com.apple.security.cs.disable-library-validation` は配布時にセキュリティリスクとなりうる。将来的には libarchive を Homebrew ではなく SPM 等でバンドルする形に移行することを検討すべき
- Hardened Runtime の設定変更が App Store 審査に影響する可能性がある（macOS App Store 提出予定がある場合は事前確認が必要）

### 必要なサポート
- 未記載

## メモ・備考

### 参考リンク
- [Apple: Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)
- [Apple: Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)
- [libarchive 公式](https://libarchive.org/)

### 相談事項
- `com.apple.security.cs.disable-library-validation` の長期的な代替手段について要検討

### 改善提案
- libarchive を SPM パッケージとしてバンドルすることで Homebrew 依存を排除し、Hardened Runtime との互換性を根本的に解決できる可能性がある

## メトリクス

| 指標 | 値 |
|---|---|
| 追加行数 | 未記載 |
| 削除行数 | 未記載 |
| 変更ファイル数 | 3（project.pbxproj, SecureZipTests.xctestplan, SecureZip.entitlements） |
| 作業時間 | 未記載 |
| 生産性 | 高（全 10 テストスイート PASSED を達成） |

## タグ
`#development` `#test-target` `#macos` `#xcode` `#hardened-runtime` `#libarchive` `#2026-03-05`

---
*作成: 2026-03-05 JST*
*最終更新: 2026-03-05 JST*
