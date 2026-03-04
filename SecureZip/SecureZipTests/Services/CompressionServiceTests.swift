import XCTest
@testable import SecureZip

final class CompressionServiceTests: XCTestCase {

    private var sut: CompressionService!
    private var tempDirectory: URL!

    override func setUpWithError() throws {
        sut = CompressionService()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        sut = nil
    }

    // MARK: - 正常系

    func testCompress_zip_withoutPassword_succeeds() async throws {
        let source = tempDirectory.appendingPathComponent("hello.txt")
        try Data("Hello, World!".utf8).write(to: source)

        let dest = tempDirectory.appendingPathComponent("out.zip")
        try await sut.compress(
            sources: [source], destination: dest,
            format: .zip, password: nil
        ) { _ in }

        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path))
    }

    func testCompress_zip_withPassword_succeeds() async throws {
        let source = tempDirectory.appendingPathComponent("secret.txt")
        let originalContent = "秘密のデータ"
        try Data(originalContent.utf8).write(to: source)

        let dest = tempDirectory.appendingPathComponent("encrypted.zip")
        let password = "TestPassword123"

        try await sut.compress(
            sources: [source], destination: dest,
            format: .zip, password: password
        ) { _ in }

        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path))

        // 正しいパスワードで解凍し内容一致を検証
        let extractDir = tempDirectory.appendingPathComponent("extracted")
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
        try await sut.decompress(
            source: dest, destination: extractDir, password: password
        ) { _ in }

        let restoredURL = extractDir.appendingPathComponent("secret.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: restoredURL.path))
        let restoredContent = try String(contentsOf: restoredURL, encoding: .utf8)
        XCTAssertEqual(restoredContent, originalContent)
    }

    func testCompress_tarGz_succeeds() async throws {
        let source = tempDirectory.appendingPathComponent("data.txt")
        try Data("TAR data".utf8).write(to: source)

        let dest = tempDirectory.appendingPathComponent("out.tar.gz")
        try await sut.compress(
            sources: [source], destination: dest,
            format: .tarGz, password: nil
        ) { _ in }

        XCTAssertTrue(FileManager.default.fileExists(atPath: dest.path))
    }

    func testDecompress_zip_withoutPassword_succeeds() async throws {
        let source = tempDirectory.appendingPathComponent("roundtrip.txt")
        let originalContent = "Round-trip test content"
        try Data(originalContent.utf8).write(to: source)

        let zipPath = tempDirectory.appendingPathComponent("roundtrip.zip")
        try await sut.compress(
            sources: [source], destination: zipPath,
            format: .zip, password: nil
        ) { _ in }

        let extractDir = tempDirectory.appendingPathComponent("out")
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
        try await sut.decompress(
            source: zipPath, destination: extractDir, password: nil
        ) { _ in }

        let restoredURL = extractDir.appendingPathComponent("roundtrip.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: restoredURL.path))
        let restoredContent = try String(contentsOf: restoredURL, encoding: .utf8)
        XCTAssertEqual(restoredContent, originalContent)
    }

    func testDecompress_zip_withCorrectPassword_succeeds() async throws {
        let source = tempDirectory.appendingPathComponent("pw_test.txt")
        let originalContent = "パスワード付きZIPのテスト"
        try Data(originalContent.utf8).write(to: source)

        let zipPath = tempDirectory.appendingPathComponent("pw_test.zip")
        let password = "CorrectPass!99"
        try await sut.compress(
            sources: [source], destination: zipPath,
            format: .zip, password: password
        ) { _ in }

        let extractDir = tempDirectory.appendingPathComponent("pw_out")
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)
        try await sut.decompress(
            source: zipPath, destination: extractDir, password: password
        ) { _ in }

        let restoredURL = extractDir.appendingPathComponent("pw_test.txt")
        XCTAssertTrue(FileManager.default.fileExists(atPath: restoredURL.path))
        let restoredContent = try String(contentsOf: restoredURL, encoding: .utf8)
        XCTAssertEqual(restoredContent, originalContent)
    }

    // MARK: - 異常系

    func testCompress_withEncryption_onTarGz_throwsError() async throws {
        let source = tempDirectory.appendingPathComponent("test.txt")
        FileManager.default.createFile(atPath: source.path, contents: Data("test".utf8))
        let dest = tempDirectory.appendingPathComponent("out.tar.gz")

        do {
            try await sut.compress(
                sources: [source],
                destination: dest,
                format: .tarGz,
                password: "password"
            ) { _ in }
            XCTFail("エラーがスローされるべき")
        } catch SecureZipError.encryptionNotSupported {
            // 期待通り
        }
    }

    func testDecompress_withWrongPassword_throwsError() async throws {
        let source = tempDirectory.appendingPathComponent("locked.txt")
        try Data("機密データ".utf8).write(to: source)

        let zipPath = tempDirectory.appendingPathComponent("locked.zip")
        try await sut.compress(
            sources: [source], destination: zipPath,
            format: .zip, password: "CorrectPassword"
        ) { _ in }

        let extractDir = tempDirectory.appendingPathComponent("wrong_pw_out")
        try FileManager.default.createDirectory(at: extractDir, withIntermediateDirectories: true)

        do {
            try await sut.decompress(
                source: zipPath, destination: extractDir,
                password: "WrongPassword"
            ) { _ in }
            XCTFail("誤ったパスワードでエラーがスローされるべき")
        } catch SecureZipError.decompressionFailed {
            // 期待通り
        }
    }
}
