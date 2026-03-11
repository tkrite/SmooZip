import Foundation

/// 送付履歴の送信ステータス
enum SendStatus: String, CaseIterable {
    case created    = "created"
    case sending    = "sending"
    case sent       = "sent"
    case cancelled  = "cancelled"
    case failed     = "failed"

    /// ユーザーに表示するラベル
    var displayName: String {
        switch self {
        case .created:   return NSLocalizedString("作成済み", comment: "Send status: created")
        case .sending:   return NSLocalizedString("送信中", comment: "Send status: sending")
        case .sent:      return NSLocalizedString("送信済み", comment: "Send status: sent")
        case .cancelled: return NSLocalizedString("キャンセル済み", comment: "Send status: cancelled")
        case .failed:    return NSLocalizedString("失敗", comment: "Send status: failed")
        }
    }

    /// アイコン名（SF Symbols）
    var symbolName: String {
        switch self {
        case .created:   return "doc"
        case .sending:   return "arrow.up.circle"
        case .sent:      return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle"
        case .failed:    return "exclamationmark.circle"
        }
    }
}
