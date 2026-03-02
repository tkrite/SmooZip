import Foundation
import Observation

@Observable
final class SendViewModel {

    // MARK: - State

    var recipientEmail: String = ""
    var subject: String = ""
    var body: String = ""
    var selectedFile: URL?
    var password: String = ""
    var isSeparatePasswordEnabled: Bool = true
    var cancelDelaySeconds: Int = 5
    var countdown: Int = 0
    var isSending: Bool = false
    var isCountingDown: Bool = false
    var errorMessage: String?
    var isCompleted: Bool = false

    // MARK: - Dependencies

    private let gmailService: GmailServiceProtocol
    private let passwordService: PasswordServiceProtocol
    private var sendTask: Task<Void, Error>?

    init(gmailService: GmailServiceProtocol = GmailService(),
         passwordService: PasswordServiceProtocol = PasswordService()) {
        self.gmailService = gmailService
        self.passwordService = passwordService
    }

    var isGmailAuthenticated: Bool { gmailService.isAuthenticated }

    // MARK: - Validation

    var canSend: Bool {
        recipientEmail.isValidEmail
        && selectedFile != nil
        && !isSending
        && gmailService.isAuthenticated
    }

    // MARK: - Actions

    /// 送信ボタン押下 → カウントダウン開始
    func startSending() {
        guard canSend, let file = selectedFile else { return }
        isCountingDown = true
        countdown = cancelDelaySeconds

        sendTask = Task {
            // カウントダウン（キャンセル・エラーは早期リターン）
            do {
                for remaining in stride(from: cancelDelaySeconds, through: 1, by: -1) {
                    try Task.checkCancellation()
                    await MainActor.run { countdown = remaining }
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                }
                try Task.checkCancellation()
            } catch {
                await MainActor.run {
                    isCountingDown = false
                    countdown = 0
                }
                return
            }

            await MainActor.run {
                isCountingDown = false
                isSending = true
            }

            // 送信実行：エラー・キャンセルいずれの場合も isSending を false にリセットする
            do {
                try await gmailService.sendWithSeparatePassword(
                    file: file,
                    password: password,
                    recipient: recipientEmail,
                    subject: subject.isEmpty ? "ファイルを送付します" : subject,
                    body: body,
                    separatePassword: isSeparatePasswordEnabled
                )
                await MainActor.run {
                    isSending = false
                    isCompleted = true
                }
            } catch is CancellationError {
                await MainActor.run { isSending = false }
            } catch {
                await MainActor.run {
                    isSending = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// 送信をキャンセルする
    func cancelSending() {
        sendTask?.cancel()
        sendTask = nil
        isCountingDown = false
        isSending = false
        countdown = 0
    }

    func generatePassword() {
        password = passwordService.generatePassword(
            length: PasswordService.defaultLength,
            includeUppercase: true,
            includeLowercase: true,
            includeNumbers: true,
            includeSymbols: true
        )
    }

}
