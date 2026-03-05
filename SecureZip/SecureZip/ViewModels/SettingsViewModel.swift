import Foundation
import Combine
import GoogleSignIn

final class SettingsViewModel: ObservableObject {

    // MARK: - UserDefaults Keys

    private enum UDKey {
        static let passwordLength           = "settings.passwordLength"
        static let includeUppercase         = "settings.includeUppercase"
        static let includeLowercase         = "settings.includeLowercase"
        static let includeNumbers           = "settings.includeNumbers"
        static let includeSymbols           = "settings.includeSymbols"
        static let isAutoDeleteEnabled      = "settings.isAutoDeleteEnabled"
        static let autoDeleteDays           = "settings.autoDeleteDays"
        static let cancelDelaySeconds       = "settings.cancelDelaySeconds"
        static let separatePasswordByDefault = "settings.separatePasswordByDefault"
        static let postCompressionAction    = "settings.postCompressionAction"
    }

    // MARK: - Gmail（永続化不要: 実行時状態）

    @Published var isGmailConnected: Bool = false
    @Published var connectedEmail: String = ""

    // MARK: - Password

    @Published var passwordLength: Int
    @Published var includeUppercase: Bool
    @Published var includeLowercase: Bool
    @Published var includeNumbers: Bool
    @Published var includeSymbols: Bool

    // MARK: - AutoDelete

    @Published var isAutoDeleteEnabled: Bool
    @Published var autoDeleteDays: Int

    // MARK: - Send

    @Published var cancelDelaySeconds: Int
    @Published var separatePasswordByDefault: Bool

    // MARK: - PostCompression

    @Published var postCompressionAction: PostCompressionAction

    // MARK: - Error

    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let gmailService: GmailServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(gmailService: GmailServiceProtocol = GmailService()) {
        let ud = UserDefaults.standard

        // UserDefaults から値を読み込む（初回起動時はデフォルト値）
        self.passwordLength           = ud.object(forKey: UDKey.passwordLength) as? Int ?? 16
        self.includeUppercase         = ud.object(forKey: UDKey.includeUppercase) as? Bool ?? true
        self.includeLowercase         = ud.object(forKey: UDKey.includeLowercase) as? Bool ?? true
        self.includeNumbers           = ud.object(forKey: UDKey.includeNumbers) as? Bool ?? true
        self.includeSymbols           = ud.object(forKey: UDKey.includeSymbols) as? Bool ?? true
        self.isAutoDeleteEnabled      = ud.object(forKey: UDKey.isAutoDeleteEnabled) as? Bool ?? true
        self.autoDeleteDays           = ud.object(forKey: UDKey.autoDeleteDays) as? Int ?? 30
        self.cancelDelaySeconds       = ud.object(forKey: UDKey.cancelDelaySeconds) as? Int ?? 5
        self.separatePasswordByDefault = ud.object(forKey: UDKey.separatePasswordByDefault) as? Bool ?? true
        self.postCompressionAction    = PostCompressionAction(
            rawValue: ud.string(forKey: UDKey.postCompressionAction) ?? ""
        ) ?? .keep

        self.gmailService = gmailService
        self.isGmailConnected = gmailService.isAuthenticated
        self.connectedEmail = GIDSignIn.sharedInstance.currentUser?.profile?.email ?? ""

        // 変更を UserDefaults に自動保存
        $passwordLength
            .sink { ud.set($0, forKey: UDKey.passwordLength) }
            .store(in: &cancellables)
        $includeUppercase
            .sink { ud.set($0, forKey: UDKey.includeUppercase) }
            .store(in: &cancellables)
        $includeLowercase
            .sink { ud.set($0, forKey: UDKey.includeLowercase) }
            .store(in: &cancellables)
        $includeNumbers
            .sink { ud.set($0, forKey: UDKey.includeNumbers) }
            .store(in: &cancellables)
        $includeSymbols
            .sink { ud.set($0, forKey: UDKey.includeSymbols) }
            .store(in: &cancellables)
        $isAutoDeleteEnabled
            .sink { ud.set($0, forKey: UDKey.isAutoDeleteEnabled) }
            .store(in: &cancellables)
        $autoDeleteDays
            .sink { ud.set($0, forKey: UDKey.autoDeleteDays) }
            .store(in: &cancellables)
        $cancelDelaySeconds
            .sink { ud.set($0, forKey: UDKey.cancelDelaySeconds) }
            .store(in: &cancellables)
        $separatePasswordByDefault
            .sink { ud.set($0, forKey: UDKey.separatePasswordByDefault) }
            .store(in: &cancellables)
        $postCompressionAction
            .sink { ud.set($0.rawValue, forKey: UDKey.postCompressionAction) }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func connectGmail() async {
        errorMessage = nil
        do {
            try await gmailService.authenticate()
            isGmailConnected = gmailService.isAuthenticated
            connectedEmail = GIDSignIn.sharedInstance.currentUser?.profile?.email ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func disconnectGmail() async {
        errorMessage = nil
        do {
            try await gmailService.disconnect()
            isGmailConnected = false
            connectedEmail = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
