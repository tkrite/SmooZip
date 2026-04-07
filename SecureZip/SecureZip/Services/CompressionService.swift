import Foundation

// MARK: - Protocol

protocol CompressionServiceProtocol {
    func compress(
        sources: [URL],
        destination: URL,
        format: CompressionFormat,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws

    func decompress(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws
}

// MARK: - Implementation

/// 圧縮・解凍処理を統括するサービス
///
/// libarchive を使用してストリーミング圧縮を行う。
/// 大容量ファイルでもメモリ使用量を一定に保つ。
final class CompressionService: CompressionServiceProtocol {

    private let archiveWrapper: LibArchiveWrapper
    private let fileManager: FileManager

    init(archiveWrapper: LibArchiveWrapper = LibArchiveWrapper(),
         fileManager: FileManager = .default) {
        self.archiveWrapper = archiveWrapper
        self.fileManager = fileManager
    }

    /// ファイル/フォルダを指定形式で圧縮する
    func compress(
        sources: [URL],
        destination: URL,
        format: CompressionFormat,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        // 暗号化は ZIP 形式のみ対応
        if let _ = password, !format.supportsEncryption {
            throw SecureZipError.encryptionNotSupported(format: format)
        }
        try await archiveWrapper.compress(
            sources: sources,
            destination: destination,
            format: format,
            password: password,
            progress: progress
        )
    }

    /// 圧縮ファイルを解凍する
    func decompress(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        try await archiveWrapper.decompress(
            source: source,
            destination: destination,
            password: password,
            progress: progress
        )
    }
}

// MARK: - Error Types

enum SecureZipError: LocalizedError {
    case encryptionNotSupported(format: CompressionFormat)
    case passwordTooWeak
    case gmailNotAuthenticated
    case gmailSendFailed(statusCode: Int, message: String)
    case fileTooLarge(size: Int64, limit: Int64)
    case fileAccessDenied(url: URL)
    case keychainError(status: OSStatus)
    case coreDataError(underlying: Error)
    case compressionFailed(underlying: Error)
    case decompressionFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .encryptionNotSupported(let format):
            return String(format: NSLocalizedString("error.encryptionNotSupported", comment: ""), format.displayName)
        case .passwordTooWeak:
            return NSLocalizedString("error.passwordTooWeak", comment: "")
        case .gmailNotAuthenticated:
            return NSLocalizedString("error.gmailNotAuthenticated", comment: "")
        case .gmailSendFailed(let code, let msg):
            return String(format: NSLocalizedString("error.gmailSendFailed", comment: ""), code, msg)
        case .fileTooLarge(let size, let limit):
            return String(format: NSLocalizedString("error.fileTooLarge", comment: ""),
                          ByteCountFormatter.string(fromByteCount: size, countStyle: .file),
                          ByteCountFormatter.string(fromByteCount: limit, countStyle: .file))
        case .fileAccessDenied(let url):
            return String(format: NSLocalizedString("error.fileAccessDenied", comment: ""), url.lastPathComponent)
        case .keychainError(let status):
            return String(format: NSLocalizedString("error.keychainError", comment: ""), status)
        case .coreDataError(let err):
            return String(format: NSLocalizedString("error.coreDataError", comment: ""), err.localizedDescription)
        case .compressionFailed(let err):
            return String(format: NSLocalizedString("error.compressionFailed", comment: ""), err.localizedDescription)
        case .decompressionFailed(let err):
            return String(format: NSLocalizedString("error.decompressionFailed", comment: ""), err.localizedDescription)
        }
    }
}
