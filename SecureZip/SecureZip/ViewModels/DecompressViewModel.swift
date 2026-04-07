import Foundation
import Combine

@MainActor
final class DecompressViewModel: ObservableObject {

    @Published var selectedFile: URL?
    @Published var password: String = ""
    @Published var progress: Double = 0
    @Published var isDecompressing: Bool = false
    @Published var errorMessage: String?
    @Published var isCompleted: Bool = false

    private let compressionService: CompressionServiceProtocol

    init(compressionService: CompressionServiceProtocol = CompressionService()) {
        self.compressionService = compressionService
    }

    func decompress(destination: URL) async {
        guard let source = selectedFile else { return }
        isDecompressing = true
        progress = 0
        errorMessage = nil
        isCompleted = false

        guard source.startAccessingSecurityScopedResource() else {
            errorMessage = NSLocalizedString("error.fileAccess.generic", comment: "")
            isDecompressing = false
            return
        }
        defer { source.stopAccessingSecurityScopedResource() }

        do {
            try await compressionService.decompress(
                source: source,
                destination: destination,
                password: password.isEmpty ? nil : password
            ) { [weak self] p in
                Task { @MainActor [weak self] in self?.progress = p }
            }
            isCompleted = true
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        isDecompressing = false
    }

    var canDecompress: Bool { selectedFile != nil }
}
