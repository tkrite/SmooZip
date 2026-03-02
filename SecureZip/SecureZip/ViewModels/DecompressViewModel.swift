import Foundation
import Observation

@Observable
final class DecompressViewModel {

    var selectedFile: URL?
    var password: String = ""
    var progress: Double = 0
    var isDecompressing: Bool = false
    var errorMessage: String?
    var isCompleted: Bool = false

    private let compressionService: CompressionServiceProtocol

    init(compressionService: CompressionServiceProtocol = CompressionService()) {
        self.compressionService = compressionService
    }

    @MainActor
    func decompress(destination: URL) async {
        guard let source = selectedFile else { return }
        isDecompressing = true
        progress = 0
        errorMessage = nil
        isCompleted = false

        do {
            try await compressionService.decompress(
                source: source,
                destination: destination,
                password: password.isEmpty ? nil : password
            ) { [weak self] p in
                Task { @MainActor in self?.progress = p }
            }
            isCompleted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isDecompressing = false
    }

    var canDecompress: Bool { selectedFile != nil }
}
