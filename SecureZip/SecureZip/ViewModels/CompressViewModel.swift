import Foundation
import Combine

final class CompressViewModel: ObservableObject {

    // MARK: - State

    @Published var selectedFiles: [URL] = []
    @Published var format: CompressionFormat = .zip
    @Published var isEncryptionEnabled: Bool = false
    @Published var password: String = ""
    @Published var passwordStrength: PasswordStrength = .weak
    @Published var progress: Double = 0
    @Published var isCompressing: Bool = false
    @Published var errorMessage: String?
    @Published var outputURL: URL?

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
