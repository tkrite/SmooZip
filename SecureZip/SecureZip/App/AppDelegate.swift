import AppKit

/// URLスキームコールバック（OAuth認証後のリダイレクト）を処理する
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let autoDeleteService = AutoDeleteService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        autoDeleteService.startScheduler()
    }

    func applicationWillTerminate(_ notification: Notification) {
        autoDeleteService.stopScheduler()
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        // Google OAuth コールバック URL の処理
        // GTMAppAuth がトークン交換を行う
        for url in urls {
            NotificationCenter.default.post(
                name: .oauthCallbackReceived,
                object: url
            )
        }
    }
}

extension Notification.Name {
    static let oauthCallbackReceived = Notification.Name("oauthCallbackReceived")
}
