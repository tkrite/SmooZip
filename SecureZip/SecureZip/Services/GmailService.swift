import AppKit
import Foundation
import GoogleSignIn

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
/// OAuth 2.0 で認証し、gmail.send スコープのみで動作する。
/// GoogleSignIn SDK によるトークン管理に対応。
final class GmailService: GmailServiceProtocol {

    static let gmailSendScope = "https://www.googleapis.com/auth/gmail.send"
    static let maxAttachmentBytes: Int64 = 25 * 1024 * 1024  // 25MB
    static let passwordEmailDelayNanoseconds: UInt64 = 3_000_000_000  // 3秒

    private let apiClient: GmailAPIClient
    private let keychainService: KeychainServiceProtocol

    var isAuthenticated: Bool {
        GIDSignIn.sharedInstance.currentUser != nil
    }

    init(apiClient: GmailAPIClient = GmailAPIClient(),
         keychainService: KeychainServiceProtocol = KeychainService()) {
        self.apiClient = apiClient
        self.keychainService = keychainService
    }

    /// Gmail OAuth 認証を開始する
    func authenticate() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            DispatchQueue.main.async {
                guard let window = NSApplication.shared.keyWindow else {
                    continuation.resume(throwing: SecureZipError.gmailNotAuthenticated)
                    return
                }
                var resumed = false
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: window,
                    hint: nil,
                    additionalScopes: [Self.gmailSendScope]
                ) { result, error in
                    guard !resumed else { return }
                    resumed = true
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume()
                    }
                }
            }
        }
    }

    /// Gmail 連携を解除する
    func disconnect() async throws {
        GIDSignIn.sharedInstance.signOut()
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

        // 2. パスワード別送が有効かつパスワードが空でない場合のみ、数秒後にパスワード通知メールを送信
        guard separatePassword && !password.isEmpty else { return }
        try await Task.sleep(nanoseconds: Self.passwordEmailDelayNanoseconds)
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
