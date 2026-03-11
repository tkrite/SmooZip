import Foundation

/// 送付履歴の自動削除スケジュール管理サービス
@MainActor
final class AutoDeleteService {

    private static let checkIntervalNanoseconds: UInt64 = 3_600_000_000_000  // 1時間

    private let historyService: HistoryServiceProtocol
    private var schedulerTask: Task<Void, Never>?

    init(historyService: HistoryServiceProtocol = HistoryService()) {
        self.historyService = historyService
    }

    /// 自動削除スケジューラーを開始する（アプリ起動時に呼び出す）
    func startScheduler() {
        // アプリ起動時に即時チェック
        Task {
            do {
                try await deleteIfEnabled()
            } catch {
                #if DEBUG
                print("⚠️ AutoDeleteService: 起動時チェック失敗: \(error)")
                #endif
            }
        }

        // 1 時間ごとに期限切れ履歴を削除（構造化並行性でメインスレッド非依存）
        schedulerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: Self.checkIntervalNanoseconds)
                guard !Task.isCancelled else { break }
                try? await deleteIfEnabled()
            }
        }
    }

    private func deleteIfEnabled() async throws {
        let isEnabled = UserDefaults.standard.object(forKey: SettingsViewModel.UDKey.isAutoDeleteEnabled) as? Bool ?? true
        guard isEnabled else { return }
        try await historyService.deleteExpired()
    }

    func stopScheduler() {
        schedulerTask?.cancel()
        schedulerTask = nil
    }

}
