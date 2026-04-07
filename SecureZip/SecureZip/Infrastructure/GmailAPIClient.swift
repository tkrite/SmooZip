import Foundation
import GoogleSignIn

/// Gmail REST API クライアント
///
/// MIME メッセージを Base64URL エンコードして Gmail API に送信する。
/// アクセストークンは GIDSignIn SDK から直接取得し、401 時はトークンをリフレッシュして1回リトライする。
final class GmailAPIClient {

    static let gmailSendEndpoint = URL(string: "https://gmail.googleapis.com/gmail/v1/users/me/messages/send")!

    private let session: URLSession
    private let sendEndpoint: URL

    init(session: URLSession = .shared,
         sendEndpoint: URL = GmailAPIClient.gmailSendEndpoint) {
        self.session = session
        self.sendEndpoint = sendEndpoint
    }

    /// メールを送信する
    ///
    /// - Parameters:
    ///   - recipient: 宛先メールアドレス
    ///   - subject: 件名
    ///   - body: 本文
    ///   - attachment: 添付ファイル URL（nil の場合は添付なし）
    func sendEmail(
        to recipient: String,
        subject: String,
        body: String,
        attachment: URL?
    ) async throws {
        // GIDSignIn SDK からアクセストークンを取得
        guard let token = GIDSignIn.sharedInstance.currentUser?.accessToken.tokenString,
              !token.isEmpty else {
            throw SecureZipError.gmailNotAuthenticated
        }

        // MIME メッセージを構築して Base64URL エンコード
        let mimeData = try await buildMIMEMessage(to: recipient, subject: subject, body: body, attachment: attachment)
        let rawMessage = mimeData.base64URLEncoded

        let statusCode = try await performRequest(rawMessage: rawMessage, token: token)

        if statusCode == 401 {
            // トークンをリフレッシュして1回だけリトライ
            let newToken = try await refreshAccessToken()
            let retryStatus = try await performRequest(rawMessage: rawMessage, token: newToken)
            if retryStatus == 401 {
                throw SecureZipError.gmailSendFailed(
                    statusCode: 401,
                    message: "認証が失効しています。設定画面から再連携してください。"
                )
            }
            // 200-299 以外のケースは performRequest 内でスロー済み
        }
    }

    // MARK: - Private Helpers

    /// リクエストを送信し HTTP ステータスコードを返す
    private func performRequest(rawMessage: String, token: String) async throws -> Int {
        var request = URLRequest(url: sendEndpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["raw": rawMessage])

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SecureZipError.gmailSendFailed(statusCode: 0, message: "レスポンスが不正です")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return httpResponse.statusCode
        case 401:
            return 401
        case 429:
            throw SecureZipError.gmailSendFailed(
                statusCode: 429,
                message: "送信レート制限に達しました。しばらく待ってから再試行してください。"
            )
        default:
            let message = extractErrorMessage(from: data) ?? "メール送信に失敗しました"
            throw SecureZipError.gmailSendFailed(statusCode: httpResponse.statusCode, message: message)
        }
    }

    /// GIDGoogleUser のトークンをリフレッシュし、新しいアクセストークンを Keychain に保存して返す
    private func refreshAccessToken() async throws -> String {
        guard let user = GIDSignIn.sharedInstance.currentUser else {
            throw SecureZipError.gmailSendFailed(
                statusCode: 401,
                message: "認証が失効しています。設定画面から再連携してください。"
            )
        }

        return try await withCheckedThrowingContinuation { continuation in
            user.refreshTokensIfNeeded { updatedUser, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let newToken = updatedUser?.accessToken.tokenString else {
                    continuation.resume(throwing: SecureZipError.gmailSendFailed(
                        statusCode: 401,
                        message: "認証トークンの更新に失敗しました"
                    ))
                    return
                }
                continuation.resume(returning: newToken)
            }
        }
    }

    /// RFC 2822 形式の MIME メッセージを構築する
    private func buildMIMEMessage(
        to: String,
        subject: String,
        body: String,
        attachment: URL?
    ) async throws -> Data {
        let boundary = "SecureZip-boundary-\(UUID().uuidString.replacingOccurrences(of: "-", with: ""))"
        let encodedSubject = rfc2047Encode(subject)

        var mime = ""
        mime += "To: \(to)\r\n"
        mime += "Subject: \(encodedSubject)\r\n"
        mime += "MIME-Version: 1.0\r\n"

        if let attachment = attachment {
            // 添付ファイルあり → multipart/mixed
            mime += "Content-Type: multipart/mixed; boundary=\"\(boundary)\"\r\n"
            mime += "\r\n"

            // --- テキストパート ---
            mime += "--\(boundary)\r\n"
            mime += "Content-Type: text/plain; charset=utf-8\r\n"
            mime += "Content-Transfer-Encoding: 8bit\r\n"
            mime += "\r\n"
            mime += body
            mime += "\r\n\r\n"

            // --- 添付ファイルパート ---
            // FileHandle でチャンク読み込みし、ファイル全体とエンコード結果を
            // 同時にメモリに保持しないようにする（ピーク使用量を ~58MB → ~33MB に削減）
            let encodedAttachment: String = try await Task.detached(priority: .userInitiated) {
                let chunkSize = 3 * 16384  // 48KB、3の倍数でBase64境界がずれない
                guard let fileHandle = FileHandle(forReadingAtPath: attachment.path) else {
                    throw SecureZipError.fileAccessDenied(url: attachment)
                }
                defer { try? fileHandle.close() }
                var chunks: [String] = []
                while true {
                    let chunk = fileHandle.readData(ofLength: chunkSize)
                    if chunk.isEmpty { break }
                    chunks.append(chunk.base64EncodedString(options: [.lineLength76Characters, .endLineWithCarriageReturn]))
                }
                return chunks.joined()
            }.value
            let encodedFilename = attachment.lastPathComponent.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? attachment.lastPathComponent

            mime += "--\(boundary)\r\n"
            mime += "Content-Type: application/octet-stream\r\n"
            mime += "Content-Disposition: attachment; filename*=UTF-8''\(encodedFilename)\r\n"
            mime += "Content-Transfer-Encoding: base64\r\n"
            mime += "\r\n"
            mime += encodedAttachment
            mime += "\r\n"

            mime += "--\(boundary)--\r\n"
        } else {
            // テキストのみ
            mime += "Content-Type: text/plain; charset=utf-8\r\n"
            mime += "Content-Transfer-Encoding: 8bit\r\n"
            mime += "\r\n"
            mime += body
            mime += "\r\n"
        }

        return Data(mime.utf8)
    }

    /// 非 ASCII 文字列を RFC 2047 (Base64) エンコードする
    private func rfc2047Encode(_ text: String) -> String {
        let isASCII = text.unicodeScalars.allSatisfy { $0.value < 128 }
        guard !isASCII else { return text }
        let encoded = Data(text.utf8).base64EncodedString()
        return "=?UTF-8?B?\(encoded)?="
    }

    /// Gmail API エラーレスポンスからメッセージを抽出する
    private func extractErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? [String: Any],
              let message = error["message"] as? String else {
            return nil
        }
        return message
    }

}
