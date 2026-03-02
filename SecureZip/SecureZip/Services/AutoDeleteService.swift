import Foundation

/// 送付履歴の自動削除スケジュール管理サービス
@MainActor
final class AutoDeleteService {

    private let historyService: HistoryServiceProtocol
    private var timer: Timer?

    init(historyService: HistoryServiceProtocol = HistoryService()) {
        self.historyService = historyService
    }

    /// 自動削除タイマーを開始する（アプリ起動時に呼び出す）
    func startScheduler() {
        // アプリ起動時に即時チェック
        Task { try? await historyService.deleteExpired() }

        // 1 時間ごとに期限切れ履歴を削除
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { try? await self?.historyService.deleteExpired() }
        }
    }

    func stopScheduler() {
        timer?.invalidate()
        timer = nil
    }

    deinit { timer?.invalidate() }
}
