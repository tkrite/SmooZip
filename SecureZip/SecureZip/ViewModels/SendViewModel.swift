import Foundation
import Combine

@MainActor
final class SendViewModel: ObservableObject {

    // MARK: - State

    @Published var recipientEmail: String = ""
    @Published var subject: String = ""
    @Published var body: String = ""
    @Published var selectedFile: URL?
    @Published var archiveFileName: String = ""
    @Published var password: String = ""
    @Published var isSeparatePasswordEnabled: Bool = true
    @Published var cancelDelaySeconds: Int = 5
    @Published var countdown: Int = 0
    @Published var isSending: Bool = false
    @Published var isCountingDown: Bool = false
    @Published var errorMessage: String?
    @Published var isCompleted: Bool = false
    @Published var showPasswordEmailWarning: Bool = false

    // MARK: - Dependencies

    private let gmailService: GmailServiceProtocol
    private let compressionService: CompressionServiceProtocol
    private let passwordService: PasswordServiceProtocol
    private let historyService: HistoryServiceProtocol
    private var sendTask: Task<Void, Error>?

    init(gmailService: GmailServiceProtocol = GmailService(),
         compressionService: CompressionServiceProtocol = CompressionService(),
         passwordService: PasswordServiceProtocol = PasswordService(),
         historyService: HistoryServiceProtocol = HistoryService()) {
        self.gmailService = gmailService
        self.compressionService = compressionService
        self.passwordService = passwordService
        self.historyService = historyService

        let ud = UserDefaults.standard
        self.cancelDelaySeconds = ud.object(forKey: SettingsViewModel.UDKey.cancelDelaySeconds) as? Int ?? 5
        self.isSeparatePasswordEnabled = ud.object(forKey: SettingsViewModel.UDKey.separatePasswordByDefault) as? Bool ?? true
    }

    var isGmailAuthenticated: Bool { gmailService.isAuthenticated }

    /// ファイルを選択し、アーカイブファイル名のデフォルト値を設定する
    func selectFile(_ url: URL) {
        selectedFile = url
        archiveFileName = url.deletingPathExtension().lastPathComponent
    }

    // MARK: - Validation

    var canSend: Bool {
        recipientEmail.isValidEmail
        && selectedFile != nil
        && !isSending
        && gmailService.isAuthenticated
    }

    // MARK: - Actions

    /// 送信ボタン押下 → パスワード別送が有効な場合は確認ダイアログを表示し、それ以外はそのまま開始
    func requestSend() {
        guard canSend else { return }
        if isSeparatePasswordEnabled && !password.isEmpty {
            showPasswordEmailWarning = true
        } else {
            startSending()
        }
    }

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
            // UUID をディレクトリ名に使い、ユーザー指定のファイル名を添付名として使用する
            let finalName = archiveFileName.trimmingCharacters(in: .whitespaces).isEmpty
                ? file.deletingPathExtension().lastPathComponent
                : archiveFileName.trimmingCharacters(in: .whitespaces)
            let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
            try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
            let archiveURL = tempDir.appendingPathComponent(finalName + ".zip")
            defer { try? FileManager.default.removeItem(at: tempDir) }

            do {
                guard file.startAccessingSecurityScopedResource() else {
                    throw SecureZipError.fileAccessDenied(url: file)
                }
                defer { file.stopAccessingSecurityScopedResource() }

            // 送信前に ZIP 圧縮（パスワードがあれば AES-256 暗号化）
                try await compressionService.compress(
                    sources: [file],
                    destination: archiveURL,
                    format: .zip,
                    password: password.isEmpty ? nil : password,
                    progress: { _ in }
                )
                try Task.checkCancellation()

                try await gmailService.sendWithSeparatePassword(
                    file: archiveURL,
                    password: password,
                    recipient: recipientEmail,
                    subject: subject.isEmpty ? NSLocalizedString("send.default.subject", comment: "") : subject,
                    body: body,
                    separatePassword: isSeparatePasswordEnabled && !password.isEmpty
                )
                await MainActor.run {
                    isSending = false
                    isCompleted = true
                    password = ""
                }
                // 送信成功後に履歴を保存（失敗しても送信完了扱いとする）
                let fileSize = (try? archiveURL.resourceValues(forKeys: [.fileSizeKey]).fileSize).flatMap { Int64($0) } ?? 0
                let historyItem = HistoryItem(
                    id: UUID(),
                    recipientEmail: recipientEmail,
                    fileName: archiveURL.lastPathComponent,
                    originalFileNames: [file.lastPathComponent],
                    fileSize: fileSize,
                    format: .zip,
                    isEncrypted: !password.isEmpty,
                    sentAt: Date(),
                    expiresAt: Calendar.current.date(byAdding: .day, value: UserDefaults.standard.object(forKey: SettingsViewModel.UDKey.autoDeleteDays) as? Int ?? 30, to: Date()),
                    status: .sent,
                    createdAt: Date()
                )
                try? await historyService.save(historyItem)
            } catch is CancellationError {
                await MainActor.run {
                    isSending = false
                    isCountingDown = false
                    isCompleted = false
                    countdown = 0
                    password = ""
                }
            } catch {
                await MainActor.run {
                    isSending = false
                    isCompleted = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    /// 送信をキャンセルする
    @MainActor
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
