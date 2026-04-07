import AppKit
import GoogleSignIn

/// URLスキームコールバック（OAuth認証後のリダイレクト）を処理する
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var autoDeleteService = AutoDeleteService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        autoDeleteService.startScheduler()
        // 既存の Google サインイン状態を復元
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error {
                NSLog("[AppDelegate] restorePreviousSignIn failed: \(error.localizedDescription)")
            }
            NotificationCenter.default.post(
                name: .gmailAuthStateChanged,
                object: user != nil
            )
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        autoDeleteService.stopScheduler()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            GIDSignIn.sharedInstance.handle(url)
        }
    }
}

extension Notification.Name {
    static let gmailAuthStateChanged = Notification.Name("gmailAuthStateChanged")
}
