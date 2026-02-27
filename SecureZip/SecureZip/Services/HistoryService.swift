import Foundation
import CoreData

// MARK: - Protocol

protocol HistoryServiceProtocol {
    func fetchAll() async throws -> [HistoryItem]
    func save(_ item: HistoryItem) async throws
    func delete(id: UUID) async throws
    func deleteExpired() async throws
}

// MARK: - DTO

struct HistoryItem: Identifiable, Sendable {
    let id: UUID
    let recipientEmail: String
    let fileName: String
    let originalFileNames: [String]
    let fileSize: Int64
    let format: CompressionFormat
    let isEncrypted: Bool
    var sentAt: Date?
    var expiresAt: Date?
    var status: SendStatus
    let createdAt: Date
}

// MARK: - Implementation

/// 送付履歴の CRUD を管理するサービス
final class HistoryService: HistoryServiceProtocol {

    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Fetch

    func fetchAll() async throws -> [HistoryItem] {
        try await coreDataStack.performBackground { context in
            let request = NSFetchRequest<NSManagedObject>(entityName: "SendHistoryEntity")
            request.sortDescriptors = [
                NSSortDescriptor(key: "createdAt", ascending: false)
            ]
            let results = try context.fetch(request)
            return results.compactMap { Self.toHistoryItem($0) }
        }
    }

    // MARK: - Save

    func save(_ item: HistoryItem) async throws {
        try await coreDataStack.performBackground { [weak self] context in
            guard let self else { return }

            // Recipient を upsert
            let recipientRequest = NSFetchRequest<NSManagedObject>(entityName: "RecipientEntity")
            recipientRequest.predicate = NSPredicate(format: "email == %@", item.recipientEmail)
            let existingRecipient = try context.fetch(recipientRequest).first

            let recipientId: UUID
            if let existing = existingRecipient {
                recipientId = existing.value(forKey: "id") as? UUID ?? UUID()
                existing.setValue(Date(), forKey: "updatedAt")
            } else {
                let newRecipient = NSManagedObject(
                    entity: context.persistentStoreCoordinator!.managedObjectModel
                        .entitiesByName["RecipientEntity"]!,
                    insertInto: context
                )
                recipientId = UUID()
                newRecipient.setValue(recipientId, forKey: "id")
                newRecipient.setValue(item.recipientEmail, forKey: "email")
                newRecipient.setValue(Date(), forKey: "createdAt")
                newRecipient.setValue(Date(), forKey: "updatedAt")
            }

            // SendHistory を保存
            let historyObj = NSManagedObject(
                entity: context.persistentStoreCoordinator!.managedObjectModel
                    .entitiesByName["SendHistoryEntity"]!,
                insertInto: context
            )
            historyObj.setValue(item.id, forKey: "id")
            historyObj.setValue(recipientId, forKey: "recipientId")
            historyObj.setValue(item.recipientEmail, forKey: "recipientEmail")
            historyObj.setValue(item.fileName, forKey: "fileName")
            historyObj.setValue(
                (try? JSONEncoder().encode(item.originalFileNames))
                    .flatMap { String(data: $0, encoding: .utf8) } ?? "[]",
                forKey: "originalFileNames"
            )
            historyObj.setValue(item.fileSize, forKey: "fileSize")
            historyObj.setValue(item.format.rawValue, forKey: "format")
            historyObj.setValue(item.isEncrypted, forKey: "isEncrypted")
            historyObj.setValue(item.sentAt, forKey: "sentAt")
            historyObj.setValue(item.expiresAt, forKey: "expiresAt")
            historyObj.setValue(item.status.rawValue, forKey: "status")
            historyObj.setValue(item.createdAt, forKey: "createdAt")

            try self.coreDataStack.save(context: context)
        }
    }

    // MARK: - Delete

    func delete(id: UUID) async throws {
        try await coreDataStack.performBackground { [weak self] context in
            guard let self else { return }
            let request = NSFetchRequest<NSManagedObject>(entityName: "SendHistoryEntity")
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            let results = try context.fetch(request)
            results.forEach { context.delete($0) }
            try self.coreDataStack.save(context: context)
        }
    }

    /// expiresAt が現在時刻を過ぎた履歴を削除する
    func deleteExpired() async throws {
        try await coreDataStack.performBackground { [weak self] context in
            guard let self else { return }
            let request = NSFetchRequest<NSManagedObject>(entityName: "SendHistoryEntity")
            request.predicate = NSPredicate(
                format: "expiresAt != nil AND expiresAt < %@",
                Date() as NSDate
            )
            let expired = try context.fetch(request)
            for obj in expired {
                // 対応する Keychain パスワードも削除
                if let id = obj.value(forKey: "id") as? UUID {
                    try? KeychainService().deletePassword(historyID: id)
                }
                context.delete(obj)
            }
            try self.coreDataStack.save(context: context)
        }
    }

    // MARK: - Mapping

    private static func toHistoryItem(_ obj: NSManagedObject) -> HistoryItem? {
        guard
            let id = obj.value(forKey: "id") as? UUID,
            let fileName = obj.value(forKey: "fileName") as? String,
            let fileSize = obj.value(forKey: "fileSize") as? Int64,
            let formatRaw = obj.value(forKey: "format") as? String,
            let format = CompressionFormat(rawValue: formatRaw),
            let isEncrypted = obj.value(forKey: "isEncrypted") as? Bool,
            let statusRaw = obj.value(forKey: "status") as? String,
            let status = SendStatus(rawValue: statusRaw),
            let createdAt = obj.value(forKey: "createdAt") as? Date
        else { return nil }

        let originalFileNamesJSON = obj.value(forKey: "originalFileNames") as? String ?? "[]"
        let originalFileNames = (try? JSONDecoder().decode(
            [String].self,
            from: Data(originalFileNamesJSON.utf8)
        )) ?? []

        let recipientEmail = obj.value(forKey: "recipientEmail") as? String ?? ""

        return HistoryItem(
            id: id,
            recipientEmail: recipientEmail,
            fileName: fileName,
            originalFileNames: originalFileNames,
            fileSize: fileSize,
            format: format,
            isEncrypted: isEncrypted,
            sentAt: obj.value(forKey: "sentAt") as? Date,
            expiresAt: obj.value(forKey: "expiresAt") as? Date,
            status: status,
            createdAt: createdAt
        )
    }
}
