import XCTest
@testable import SecureZip

// MARK: - Mocks

private final class MockGmailService: GmailServiceProtocol {
    var isAuthenticated: Bool = true
    var sendError: Error?
    var sendCallCount = 0

    func authenticate() async throws {}
    func disconnect() async throws {}

    func sendWithSeparatePassword(
        file: URL,
        password: String,
        recipient: String,
        subject: String,
        body: String,
        separatePassword: Bool
    ) async throws {
        sendCallCount += 1
        if let error = sendError { throw error }
    }
}

private final class MockPasswordService: PasswordServiceProtocol {
    static let fixedPassword = "MockP@ss1234!"

    func generatePassword(
        length: Int,
        includeUppercase: Bool,
        includeLowercase: Bool,
        includeNumbers: Bool,
        includeSymbols: Bool
    ) -> String { Self.fixedPassword }

    func evaluateStrength(_ password: String) -> PasswordStrength { .strong }
}

private final class MockCompressionService: CompressionServiceProtocol {
    var compressError: Error?

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
        progress(1.0)
    }
}

private final class MockHistoryService: HistoryServiceProtocol {
    func fetchAll() async throws -> [HistoryItem] { [] }
    func save(_ item: HistoryItem) async throws {}
    func delete(id: UUID) async throws {}
    func deleteExpired() async throws {}
}

// MARK: - Helpers

/// 条件が満たされるか、タイムアウトまでポーリングする
private func waitUntil(
    timeout: TimeInterval = 3.0,
    condition: @MainActor () -> Bool
) async {
    let deadline = Date().addingTimeInterval(timeout)
    while await !condition() && Date() < deadline {
        try? await Task.sleep(nanoseconds: 10_000_000)  // 10ms
    }
}

// MARK: - Tests

@MainActor
final class SendViewModelTests: XCTestCase {

    private var sut: SendViewModel!
    private var gmailService: MockGmailService!
    private var compressionService: MockCompressionService!
    private var passwordService: MockPasswordService!
    private var historyService: MockHistoryService!

    override func setUp() {
        gmailService = MockGmailService()
        compressionService = MockCompressionService()
        passwordService = MockPasswordService()
        historyService = MockHistoryService()
        sut = SendViewModel(
            gmailService: gmailService,
            compressionService: compressionService,
            passwordService: passwordService,
            historyService: historyService
        )
        sut.cancelDelaySeconds = 0  // カウントダウンをスキップしてテストを高速化
    }

    override func tearDown() {
        sut.cancelSending()
        sut = nil
    }

    // MARK: - canSend バリデーション

    func testCanSend_noEmail_isFalse() {
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_invalidEmail_isFalse() {
        sut.recipientEmail = "invalid-email"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_notAuthenticated_isFalse() {
        gmailService.isAuthenticated = false
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_noFile_isFalse() {
        sut.recipientEmail = "user@example.com"
        XCTAssertFalse(sut.canSend)
    }

    func testCanSend_allConditionsMet_isTrue() {
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")
        XCTAssertTrue(sut.canSend)
    }

    // MARK: - startSending / カウントダウン

    func testStartSending_setsIsCountingDownTrue() {
        sut.cancelDelaySeconds = 3  // カウントダウンあり
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()

        XCTAssertTrue(sut.isCountingDown)
        sut.cancelSending()
    }

    func testStartSending_setsCountdownToDelaySeconds() {
        sut.cancelDelaySeconds = 5
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()

        XCTAssertEqual(sut.countdown, 5)
        sut.cancelSending()
    }

    func testStartSending_cannotSend_doesNothing() {
        // selectedFile が nil のため canSend = false
        sut.startSending()
        XCTAssertFalse(sut.isCountingDown)
        XCTAssertFalse(sut.isSending)
    }

    // MARK: - cancelSending

    func testCancelSending_resetsAllState() {
        sut.cancelDelaySeconds = 3
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")
        sut.startSending()

        sut.cancelSending()

        XCTAssertFalse(sut.isCountingDown)
        XCTAssertFalse(sut.isSending)
        XCTAssertEqual(sut.countdown, 0)
    }

    func testCancelSending_whenIdle_doesNotCrash() {
        // 送信中でない状態でキャンセルしてもクラッシュしないこと
        sut.cancelSending()
        XCTAssertFalse(sut.isCountingDown)
        XCTAssertFalse(sut.isSending)
    }

    // MARK: - 送信成功フロー

    func testSendSuccess_setsIsCompleted() async {
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()
        await waitUntil { self.sut.isCompleted }

        XCTAssertTrue(sut.isCompleted)
        XCTAssertFalse(sut.isSending)
        XCTAssertNil(sut.errorMessage)
    }

    func testSendSuccess_callsGmailServiceOnce() async {
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()
        await waitUntil { self.sut.isCompleted }

        XCTAssertEqual(gmailService.sendCallCount, 1)
    }

    // MARK: - 送信エラーフロー

    func testSendError_setsErrorMessage() async {
        gmailService.sendError = SecureZipError.gmailSendFailed(
            statusCode: 500,
            message: "Internal Server Error"
        )
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()
        await waitUntil { self.sut.errorMessage != nil }

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertFalse(sut.isSending)
        XCTAssertFalse(sut.isCompleted)
    }

    func testSendError_resetsIsSending() async {
        gmailService.sendError = SecureZipError.gmailNotAuthenticated
        sut.recipientEmail = "user@example.com"
        sut.selectedFile = URL(fileURLWithPath: "/tmp/test.zip")

        sut.startSending()
        await waitUntil { !self.sut.isSending && !self.sut.isCountingDown }

        XCTAssertFalse(sut.isSending)
    }

    // MARK: - generatePassword

    func testGeneratePassword_setsPasswordFromService() {
        sut.generatePassword()
        XCTAssertEqual(sut.password, MockPasswordService.fixedPassword)
    }

    func testGeneratePassword_setsNonEmptyPassword() {
        sut.generatePassword()
        XCTAssertFalse(sut.password.isEmpty)
    }
}
