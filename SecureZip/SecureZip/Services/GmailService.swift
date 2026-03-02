import Foundation

// MARK: - Protocol

protocol GmailServiceProtocol {
    var isAuthenticated: Bool { get }
    func authenticate() async throws
    func disconnect() async throws
    func sendWithSeparatePassword(
        file: URL,
        password: String,
        recipient: String,
        subject: String,
        body: String,
        separatePassword: Bool
    ) async throws
}

// MARK: - Implementation

/// Gmail API 連携によるメール送信サービス
///
/// OAuth 2.0 + PKCE で認証し、gmail.send スコープのみで動作する。
/// GTMAppAuth によるトークン自動リフレッシュに対応。
final class GmailService: GmailServiceProtocol {

    static let gmailSendScope = "https://www.googleapis.com/auth/gmail.send"
    static let maxAttachmentBytes: Int64 = 25 * 1024 * 1024  // 25MB

    private let apiClient: GmailAPIClient
    private let keychainService: KeychainServiceProtocol

    private(set) var isAuthenticated: Bool = false

    init(apiClient: GmailAPIClient = GmailAPIClient(),
         keychainService: KeychainServiceProtocol = KeychainService()) {
        self.apiClient = apiClient
        self.keychainService = keychainService
    }

    /// Gmail OAuth 認証を開始する（Safari 経由でブラウザを開く）
    func authenticate() async throws {
        // TODO: Google Sign-In SDK を使用した OAuth 2.0 + PKCE 認証フローを実装
        // 1. GoogleSignIn.sharedInstance.signIn() を呼び出す
        // 2. トークンを Keychain に保存
        // 3. isAuthenticated = true にセット
        // OAuth 実装が完了するまでは未実装として明示的にエラーをスローする
        throw SecureZipError.gmailNotAuthenticated
    }

    /// Gmail 連携を解除する
    func disconnect() async throws {
        // TODO: Google Sign-In SDK のサインアウト処理を実装
        // トークンを Keychain から削除
        try keychainService.delete(for: KeychainKey.gmailAccessToken.rawValue)
        try keychainService.delete(for: KeychainKey.gmailRefreshToken.rawValue)
        isAuthenticated = false
    }

    /// 暗号化ファイルを送信する
    ///
    /// - Parameters:
    ///   - separatePassword: true の場合、数秒後にパスワード通知メールを別送する
    func sendWithSeparatePassword(
        file: URL,
        password: String,
        recipient: String,
        subject: String,
        body: String,
        separatePassword: Bool
    ) async throws {
        guard isAuthenticated else {
            throw SecureZipError.gmailNotAuthenticated
        }

        // ファイルサイズチェック
        let fileSize = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize).flatMap { Int64($0) } ?? 0
        if fileSize > Self.maxAttachmentBytes {
            throw SecureZipError.fileTooLarge(size: fileSize, limit: Self.maxAttachmentBytes)
        }

        // 1. 本体メール送信
        try await apiClient.sendEmail(
            to: recipient,
            subject: subject,
            body: body,
            attachment: file
        )

        // 2. パスワード別送が有効な場合のみ、数秒後にパスワード通知メールを送信
        guard separatePassword else { return }
        try await Task.sleep(nanoseconds: 3_000_000_000)
        let passwordSubject = "【パスワード通知】\(subject)"
        let passwordBody = "先ほど送付したファイルのパスワードは以下の通りです。\n\nパスワード: \(password)\n\n※このメールは自動送信されています。"
        try await apiClient.sendEmail(
            to: recipient,
            subject: passwordSubject,
            body: passwordBody,
            attachment: nil
        )
    }
}
