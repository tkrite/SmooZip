import Foundation
import Observation

@Observable
final class CompressViewModel {

    // MARK: - State

    var selectedFiles: [URL] = []
    var format: CompressionFormat = .zip
    var isEncryptionEnabled: Bool = false
    var password: String = ""
    var passwordStrength: PasswordStrength = .weak
    var progress: Double = 0
    var isCompressing: Bool = false
    var errorMessage: String?
    var outputURL: URL?

    // MARK: - Dependencies

    private let compressionService: CompressionServiceProtocol
    private let passwordService: PasswordServiceProtocol

    init(
        compressionService: CompressionServiceProtocol = CompressionService(),
        passwordService: PasswordServiceProtocol = PasswordService()
    ) {
        self.compressionService = compressionService
        self.passwordService = passwordService
    }

    // MARK: - Actions

    func addFiles(_ urls: [URL]) {
        selectedFiles.append(contentsOf: urls)
    }

    func removeFile(at index: Int) {
        selectedFiles.remove(at: index)
    }

    func generatePassword() {
        password = passwordService.generatePassword(
            length: PasswordService.defaultLength,
            includeUppercase: true,
            includeLowercase: true,
            includeNumbers: true,
            includeSymbols: true
        )
        passwordStrength = passwordService.evaluateStrength(password)
    }

    func updatePasswordStrength() {
        passwordStrength = passwordService.evaluateStrength(password)
    }

    /// 圧縮を実行する
    @MainActor
    func compress(destination: URL) async {
        guard !selectedFiles.isEmpty else { return }
        isCompressing = true
        progress = 0
        errorMessage = nil

        do {
            let pw = isEncryptionEnabled ? password : nil
            try await compressionService.compress(
                sources: selectedFiles,
                destination: destination,
                format: format,
                password: pw
            ) { [weak self] p in
                Task { @MainActor in self?.progress = p }
            }
            outputURL = destination
        } catch {
            errorMessage = error.localizedDescription
        }
        isCompressing = false
    }

    var canCompress: Bool {
        !selectedFiles.isEmpty && (!isEncryptionEnabled || !password.isEmpty)
    }
}
