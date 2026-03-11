import Foundation

/// パスワード強度の分類
enum PasswordStrength: Int, Comparable {
    case weak     = 0
    case fair     = 1
    case good     = 2
    case strong   = 3

    static func < (lhs: PasswordStrength, rhs: PasswordStrength) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// ユーザーに表示するラベル
    var displayName: String {
        switch self {
        case .weak:   return NSLocalizedString("弱い", comment: "Password strength: weak")
        case .fair:   return NSLocalizedString("普通", comment: "Password strength: fair")
        case .good:   return NSLocalizedString("良い", comment: "Password strength: good")
        case .strong: return NSLocalizedString("強い", comment: "Password strength: strong")
        }
    }

    /// アイコン名（SF Symbols）
    var symbolName: String {
        switch self {
        case .weak:   return "exclamationmark.shield"
        case .fair:   return "shield"
        case .good:   return "checkmark.shield"
        case .strong: return "lock.shield.fill"
        }
    }
}
