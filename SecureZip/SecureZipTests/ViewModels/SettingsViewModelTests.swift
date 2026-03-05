import XCTest
@testable import SecureZip

// MARK: - Mock

private final class MockGmailService: GmailServiceProtocol {
    var isAuthenticated: Bool = false
    var authenticateError: Error?
    var disconnectError: Error?

    func authenticate() async throws {
        if let error = authenticateError { throw error }
        isAuthenticated = true
    }
    func disconnect() async throws {
        if let error = disconnectError { throw error }
        isAuthenticated = false
    }
    func sendWithSeparatePassword(
        file: URL, password: String, recipient: String,
        subject: String, body: String, separatePassword: Bool
    ) async throws {}
}

// MARK: - Tests

@MainActor
final class SettingsViewModelTests: XCTestCase {

    private var sut: SettingsViewModel!
    private var gmailService: MockGmailService!

    // テスト用の UserDefaults キー（SettingsViewModel と同一）
    private let udKeys = [
        "settings.passwordLength",
        "settings.includeUppercase",
        "settings.includeLowercase",
        "settings.includeNumbers",
        "settings.includeSymbols",
        "settings.isAutoDeleteEnabled",
        "settings.autoDeleteDays",
        "settings.cancelDelaySeconds",
        "settings.separatePasswordByDefault",
        "settings.postCompressionAction"
    ]

    override func setUp() {
        cleanupUserDefaults()
        gmailService = MockGmailService()
        sut = SettingsViewModel(gmailService: gmailService)
    }

    override func tearDown() {
        sut = nil
        gmailService = nil
        cleanupUserDefaults()
    }

    private func cleanupUserDefaults() {
        udKeys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
    }

    // MARK: - デフォルト値

    func testDefaultValues_passwordLength_is16() {
        XCTAssertEqual(sut.passwordLength, 16)
    }

    func testDefaultValues_includeOptions_areAllTrue() {
        XCTAssertTrue(sut.includeUppercase)
        XCTAssertTrue(sut.includeLowercase)
        XCTAssertTrue(sut.includeNumbers)
        XCTAssertTrue(sut.includeSymbols)
    }

    func testDefaultValues_autoDelete_isEnabledWith30Days() {
        XCTAssertTrue(sut.isAutoDeleteEnabled)
        XCTAssertEqual(sut.autoDeleteDays, 30)
    }

    func testDefaultValues_cancelDelay_is5Seconds() {
        XCTAssertEqual(sut.cancelDelaySeconds, 5)
    }

    func testDefaultValues_separatePasswordByDefault_isTrue() {
        XCTAssertTrue(sut.separatePasswordByDefault)
    }

    func testDefaultValues_postCompressionAction_isKeep() {
        XCTAssertEqual(sut.postCompressionAction, .keep)
    }

    // MARK: - UserDefaults 永続化

    func testPersistence_passwordLength_isSavedToUserDefaults() {
        sut.passwordLength = 24

        let saved = UserDefaults.standard.object(forKey: "settings.passwordLength") as? Int
        XCTAssertEqual(saved, 24)
    }

    func testPersistence_includeSymbols_isSavedToUserDefaults() {
        sut.includeSymbols = false

        let saved = UserDefaults.standard.object(forKey: "settings.includeSymbols") as? Bool
        XCTAssertEqual(saved, false)
    }

    func testPersistence_cancelDelaySeconds_isSavedToUserDefaults() {
        sut.cancelDelaySeconds = 10

        let saved = UserDefaults.standard.object(forKey: "settings.cancelDelaySeconds") as? Int
        XCTAssertEqual(saved, 10)
    }

    func testPersistence_postCompressionAction_isSavedToUserDefaults() {
        sut.postCompressionAction = .delete

        let saved = UserDefaults.standard.string(forKey: "settings.postCompressionAction")
        XCTAssertEqual(saved, PostCompressionAction.delete.rawValue)
    }

    func testPersistence_restoredOnNextInit() {
        sut.passwordLength = 20
        sut.cancelDelaySeconds = 8
        sut.includeSymbols = false

        // 新しいインスタンスで読み込み確認
        let restored = SettingsViewModel(gmailService: MockGmailService())

        XCTAssertEqual(restored.passwordLength, 20)
        XCTAssertEqual(restored.cancelDelaySeconds, 8)
        XCTAssertFalse(restored.includeSymbols)
    }

    // MARK: - Gmail 連携

    func testConnectGmail_success_setsIsGmailConnected() async {
        await sut.connectGmail()

        XCTAssertTrue(sut.isGmailConnected)
        XCTAssertNil(sut.errorMessage)
    }

    func testConnectGmail_error_setsErrorMessage() async {
        gmailService.authenticateError = SecureZipError.gmailNotAuthenticated

        await sut.connectGmail()

        XCTAssertFalse(sut.isGmailConnected)
        XCTAssertNotNil(sut.errorMessage)
    }

    func testConnectGmail_clearsErrorMessageBeforeAttempt() async {
        // 前回のエラーをクリアしてから再試行すること
        gmailService.authenticateError = SecureZipError.gmailNotAuthenticated
        await sut.connectGmail()
        XCTAssertNotNil(sut.errorMessage)

        gmailService.authenticateError = nil
        await sut.connectGmail()

        XCTAssertNil(sut.errorMessage)
    }

    func testDisconnectGmail_success_resetsConnectedState() async {
        gmailService.isAuthenticated = true
        sut = SettingsViewModel(gmailService: gmailService)

        await sut.disconnectGmail()

        XCTAssertFalse(sut.isGmailConnected)
        XCTAssertEqual(sut.connectedEmail, "")
        XCTAssertNil(sut.errorMessage)
    }

    func testDisconnectGmail_error_setsErrorMessage() async {
        gmailService.disconnectError = SecureZipError.gmailNotAuthenticated

        await sut.disconnectGmail()

        XCTAssertNotNil(sut.errorMessage)
    }
}
