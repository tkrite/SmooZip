import Foundation
import Security

// MARK: - Keys

/// Keychain に保存するデータのキー定義
enum KeychainKey: String {
    case gmailAccessToken  = "com.tkrite.SecureZip.gmail.accessToken"
    case gmailRefreshToken = "com.tkrite.SecureZip.gmail.refreshToken"
    /// パスワードは "com.tkrite.SecureZip.password." + historyID で保存
    static let passwordPrefix = "com.tkrite.SecureZip.password."
}

// MARK: - Protocol

protocol KeychainServiceProtocol {
    func save(_ data: Data, for key: String) throws
    func load(for key: String) throws -> Data
    func delete(for key: String) throws
    func savePassword(_ password: String, historyID: UUID) throws
    func loadPassword(historyID: UUID) throws -> String
    func deletePassword(historyID: UUID) throws
}

// MARK: - Implementation

/// Keychain Services のラッパーサービス
///
/// パスワード・OAuth トークンをセキュアに保管する。
/// kSecAttrAccessibleWhenUnlockedThisDeviceOnly を使用し、iCloud 同期を無効化する。
final class KeychainService: KeychainServiceProtocol {

    func save(_ data: Data, for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String:                kSecClassGenericPassword,
            kSecAttrAccount as String:          key,
            kSecValueData as String:            data,
            kSecAttrAccessible as String:       kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String:   false
        ]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureZipError.keychainError(status: status)
        }
    }

    func load(for key: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrAccount as String:  key,
            kSecReturnData as String:   true,
            kSecMatchLimit as String:   kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else {
            throw SecureZipError.keychainError(status: status)
        }
        return data
    }

    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String:        kSecClassGenericPassword,
            kSecAttrAccount as String:  key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureZipError.keychainError(status: status)
        }
    }

    func savePassword(_ password: String, historyID: UUID) throws {
        let key = KeychainKey.passwordPrefix + historyID.uuidString
        guard let data = password.data(using: .utf8) else { return }
        try save(data, for: key)
    }

    func loadPassword(historyID: UUID) throws -> String {
        let key = KeychainKey.passwordPrefix + historyID.uuidString
        let data = try load(for: key)
        guard let password = String(data: data, encoding: .utf8) else {
            throw SecureZipError.keychainError(status: errSecDecode)
        }
        return password
    }

    func deletePassword(historyID: UUID) throws {
        let key = KeychainKey.passwordPrefix + historyID.uuidString
        try delete(for: key)
    }
}
