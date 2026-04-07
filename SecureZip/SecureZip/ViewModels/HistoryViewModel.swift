import Foundation
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {

    @Published var items: [HistoryItem] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let historyService: HistoryServiceProtocol

    init(historyService: HistoryServiceProtocol = HistoryService()) {
        self.historyService = historyService
    }

    var filteredItems: [HistoryItem] {
        guard !searchText.isEmpty else { return items }
        return items.filter {
            $0.recipientEmail.localizedCaseInsensitiveContains(searchText)
            || $0.fileName.localizedCaseInsensitiveContains(searchText)
        }
    }

    func loadHistory() async {
        isLoading = true
        do {
            items = try await historyService.fetchAll()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteItem(id: UUID) async {
        do {
            try await historyService.delete(id: id)
            items.removeAll { $0.id == id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteItems(ids: [UUID]) async {
        var failedIds = Set<UUID>()
        for id in ids {
            do {
                try await historyService.delete(id: id)
            } catch {
                errorMessage = error.localizedDescription
                failedIds.insert(id)
            }
        }
        items.removeAll { ids.contains($0.id) && !failedIds.contains($0.id) }
    }
}
