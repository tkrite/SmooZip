import XCTest
@testable import SecureZip

// MARK: - Mock

private final class MockHistoryService: HistoryServiceProtocol {
    var stubbedItems: [HistoryItem] = []
    var fetchError: Error?
    var deleteError: Error?
    private(set) var deletedIDs: [UUID] = []

    func fetchAll() async throws -> [HistoryItem] {
        if let error = fetchError { throw error }
        return stubbedItems
    }
    func save(_ item: HistoryItem) async throws {}
    func delete(id: UUID) async throws {
        if let error = deleteError { throw error }
        deletedIDs.append(id)
    }
    func deleteExpired() async throws {}
}

// MARK: - Helper

private func makeItem(
    id: UUID = UUID(),
    recipientEmail: String = "test@example.com",
    fileName: String = "archive.zip"
) -> HistoryItem {
    HistoryItem(
        id: id,
        recipientEmail: recipientEmail,
        fileName: fileName,
        originalFileNames: [fileName],
        fileSize: 1024,
        format: .zip,
        isEncrypted: true,
        sentAt: Date(),
        expiresAt: nil,
        status: .sent,
        createdAt: Date()
    )
}

// MARK: - Tests

@MainActor
final class HistoryViewModelTests: XCTestCase {

    private var sut: HistoryViewModel!
    private var historyService: MockHistoryService!

    override func setUp() {
        historyService = MockHistoryService()
        sut = HistoryViewModel(historyService: historyService)
    }

    override func tearDown() {
        sut = nil
        historyService = nil
    }

    // MARK: - loadHistory

    func testLoadHistory_populatesItems() async {
        historyService.stubbedItems = [makeItem(), makeItem()]

        await sut.loadHistory()

        XCTAssertEqual(sut.items.count, 2)
    }

    func testLoadHistory_setsIsLoadingTrueThenFalse() async {
        // 完了後に isLoading が false になること
        await sut.loadHistory()
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadHistory_noItems_returnsEmptyArray() async {
        await sut.loadHistory()
        XCTAssertTrue(sut.items.isEmpty)
    }

    func testLoadHistory_error_setsErrorMessage() async {
        historyService.fetchError = SecureZipError.coreDataError(
            underlying: NSError(domain: "Test", code: -1)
        )

        await sut.loadHistory()

        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.items.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func testLoadHistory_error_doesNotSetItems() async {
        historyService.stubbedItems = [makeItem()]
        historyService.fetchError = NSError(domain: "Test", code: -1)

        await sut.loadHistory()

        XCTAssertTrue(sut.items.isEmpty)
    }

    // MARK: - deleteItem

    func testDeleteItem_removesFromLocalItems() async {
        let target = makeItem()
        let other = makeItem()
        historyService.stubbedItems = [target, other]
        await sut.loadHistory()

        await sut.deleteItem(id: target.id)

        XCTAssertEqual(sut.items.count, 1)
        XCTAssertEqual(sut.items[0].id, other.id)
    }

    func testDeleteItem_callsServiceWithCorrectID() async {
        let target = makeItem()
        historyService.stubbedItems = [target]
        await sut.loadHistory()

        await sut.deleteItem(id: target.id)

        XCTAssertEqual(historyService.deletedIDs, [target.id])
    }

    func testDeleteItem_error_setsErrorMessage() async {
        let target = makeItem()
        historyService.stubbedItems = [target]
        await sut.loadHistory()
        historyService.deleteError = SecureZipError.coreDataError(
            underlying: NSError(domain: "Test", code: -1)
        )

        await sut.deleteItem(id: target.id)

        XCTAssertNotNil(sut.errorMessage)
        // エラー時はローカルの items を変更しない
        XCTAssertEqual(sut.items.count, 1)
    }

    // MARK: - filteredItems

    func testFilteredItems_emptySearchText_returnsAll() async {
        historyService.stubbedItems = [makeItem(), makeItem(), makeItem()]
        await sut.loadHistory()

        XCTAssertEqual(sut.filteredItems.count, 3)
    }

    func testFilteredItems_searchByEmail_filtersCorrectly() async {
        historyService.stubbedItems = [
            makeItem(recipientEmail: "alice@example.com"),
            makeItem(recipientEmail: "bob@example.com"),
            makeItem(recipientEmail: "alice.smith@work.com")
        ]
        await sut.loadHistory()

        sut.searchText = "alice"

        XCTAssertEqual(sut.filteredItems.count, 2)
    }

    func testFilteredItems_searchByFileName_filtersCorrectly() async {
        historyService.stubbedItems = [
            makeItem(fileName: "report_2026.zip"),
            makeItem(fileName: "photo.zip"),
            makeItem(fileName: "report_final.zip")
        ]
        await sut.loadHistory()

        sut.searchText = "report"

        XCTAssertEqual(sut.filteredItems.count, 2)
    }

    func testFilteredItems_searchIsCaseInsensitive() async {
        historyService.stubbedItems = [
            makeItem(recipientEmail: "USER@EXAMPLE.COM")
        ]
        await sut.loadHistory()

        sut.searchText = "user"

        XCTAssertEqual(sut.filteredItems.count, 1)
    }

    func testFilteredItems_noMatch_returnsEmpty() async {
        historyService.stubbedItems = [makeItem(recipientEmail: "test@example.com")]
        await sut.loadHistory()

        sut.searchText = "zzz_no_match"

        XCTAssertTrue(sut.filteredItems.isEmpty)
    }
}
