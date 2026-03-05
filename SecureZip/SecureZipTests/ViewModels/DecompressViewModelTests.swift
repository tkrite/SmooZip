import XCTest
@testable import SecureZip

// MARK: - Mock

private final class MockCompressionService: CompressionServiceProtocol {
    var compressError: Error?
    var decompressError: Error?
    private(set) var lastDecompressSource: URL?
    private(set) var lastDecompressPassword: String?

    func compress(
        sources: [URL],
        destination: URL,
        format: CompressionFormat,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        if let error = compressError { throw error }
        progress(1.0)
    }

    func decompress(
        source: URL,
        destination: URL,
        password: String?,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        lastDecompressSource = source
        lastDecompressPassword = password
        if let error = decompressError { throw error }
        progress(0.5)
        progress(1.0)
    }
}

// MARK: - Tests

@MainActor
final class DecompressViewModelTests: XCTestCase {

    private var sut: DecompressViewModel!
    private var compressionService: MockCompressionService!

    private let dummyFile = URL(fileURLWithPath: "/tmp/test.zip")
    private let dummyDestination = URL(fileURLWithPath: "/tmp/out")

    override func setUp() {
        compressionService = MockCompressionService()
        sut = DecompressViewModel(compressionService: compressionService)
    }

    override func tearDown() {
        sut = nil
        compressionService = nil
    }

    // MARK: - canDecompress

    func testCanDecompress_noFile_isFalse() {
        XCTAssertFalse(sut.canDecompress)
    }

    func testCanDecompress_withFile_isTrue() {
        sut.selectedFile = dummyFile
        XCTAssertTrue(sut.canDecompress)
    }

    // MARK: - 初期状態

    func testInitialState_isClean() {
        XCTAssertNil(sut.selectedFile)
        XCTAssertEqual(sut.password, "")
        XCTAssertEqual(sut.progress, 0)
        XCTAssertFalse(sut.isDecompressing)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isCompleted)
    }

    // MARK: - decompress 正常系

    func testDecompress_noFile_doesNothing() async {
        await sut.decompress(destination: dummyDestination)

        XCTAssertFalse(sut.isCompleted)
        XCTAssertFalse(sut.isDecompressing)
        XCTAssertNil(compressionService.lastDecompressSource)
    }

    func testDecompress_success_setsIsCompleted() async {
        sut.selectedFile = dummyFile

        await sut.decompress(destination: dummyDestination)

        XCTAssertTrue(sut.isCompleted)
        XCTAssertFalse(sut.isDecompressing)
        XCTAssertNil(sut.errorMessage)
    }

    func testDecompress_success_setsProgressToOne() async {
        sut.selectedFile = dummyFile

        await sut.decompress(destination: dummyDestination)

        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.001)
    }

    func testDecompress_resetsStateBeforeStart() async {
        // 前回の完了フラグ・エラーをクリアしてから開始すること
        sut.selectedFile = dummyFile
        await sut.decompress(destination: dummyDestination)

        compressionService.decompressError = SecureZipError.decompressionFailed(
            underlying: NSError(domain: "Test", code: -1)
        )
        await sut.decompress(destination: dummyDestination)

        XCTAssertFalse(sut.isCompleted)
        XCTAssertNotNil(sut.errorMessage)
    }

    // MARK: - decompress エラー系

    func testDecompress_error_setsErrorMessage() async {
        compressionService.decompressError = SecureZipError.decompressionFailed(
            underlying: NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "解凍失敗"])
        )
        sut.selectedFile = dummyFile

        await sut.decompress(destination: dummyDestination)

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isCompleted)
        XCTAssertFalse(sut.isDecompressing)
    }

    func testDecompress_error_doesNotSetIsCompleted() async {
        compressionService.decompressError = SecureZipError.decompressionFailed(
            underlying: NSError(domain: "Test", code: -1)
        )
        sut.selectedFile = dummyFile

        await sut.decompress(destination: dummyDestination)

        XCTAssertFalse(sut.isCompleted)
    }

    // MARK: - パスワード渡し

    func testDecompress_withPassword_passesPasswordToService() async {
        sut.selectedFile = dummyFile
        sut.password = "SecretPass123"

        await sut.decompress(destination: dummyDestination)

        XCTAssertEqual(compressionService.lastDecompressPassword, "SecretPass123")
    }

    func testDecompress_emptyPassword_passesNilToService() async {
        sut.selectedFile = dummyFile
        sut.password = ""

        await sut.decompress(destination: dummyDestination)

        XCTAssertNil(compressionService.lastDecompressPassword)
    }
}
