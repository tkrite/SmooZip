import Foundation
import CoreData

/// Core Data スタック管理
///
/// **セットアップ手順（Xcode）:**
/// 1. Xcode で `File > New > File > Data Model` を選択し `SecureZip.xcdatamodeld` を作成
/// 2. 以下のエンティティを追加:
///    - `SendHistoryEntity` (attributes: id UUID, recipientId UUID, fileName String, ...)
///    - `RecipientEntity` (attributes: id UUID, email String, name String?, ...)
///    - `AppSettingsEntity` (attributes: id UUID, key String, value String, ...)
///
/// **テスト時:** `useInMemoryStore = true` にするとファイルなしで動作します。
final class CoreDataStack {

    static let shared = CoreDataStack()

    /// テスト時はインメモリストアを使用する
    var useInMemoryStore: Bool = false

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        // xcdatamodeld が存在しない場合、またはテスト時はインメモリで代替
        if useInMemoryStore || !modelFileExists() {
            let c = makeInMemoryContainer()
            c.viewContext.automaticallyMergesChangesFromParent = true
            return c
        }

        let container = NSPersistentContainer(name: "SecureZip")
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }

        if let error = loadError {
            // ストア読み込み失敗時はインメモリコンテナへフォールバック
            print("⚠️ Core Data 読み込み失敗、インメモリで代替します: \(error)")
            let fallback = makeInMemoryContainer()
            fallback.viewContext.automaticallyMergesChangesFromParent = true
            return fallback
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    /// バックグラウンドコンテキストで処理を実行する
    func performBackground<T: Sendable>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            persistentContainer.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw SecureZipError.coreDataError(underlying: error)
        }
    }

    // MARK: - Private

    private func modelFileExists() -> Bool {
        guard let url = Bundle.main.url(forResource: "SecureZip", withExtension: "momd") else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }

    /// xcdatamodeld なしで動くインメモリコンテナ（プログラムでモデルを定義）
    private func makeInMemoryContainer() -> NSPersistentContainer {
        let model = NSManagedObjectModel()

        // SendHistory エンティティ
        let historyEntity = NSEntityDescription()
        historyEntity.name = "SendHistoryEntity"
        historyEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let historyAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .UUIDAttributeType, true),
            ("recipientId", .UUIDAttributeType, true),
            ("recipientEmail", .stringAttributeType, true),
            ("fileName", .stringAttributeType, true),
            ("originalFileNames", .stringAttributeType, true),
            ("fileSize", .integer64AttributeType, true),
            ("format", .stringAttributeType, true),
            ("isEncrypted", .booleanAttributeType, true),
            ("sentAt", .dateAttributeType, false),
            ("expiresAt", .dateAttributeType, false),
            ("status", .stringAttributeType, true),
            ("createdAt", .dateAttributeType, true),
        ]
        historyEntity.properties = historyAttributes.map { name, type, required in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = !required
            return attr
        }

        // Recipient エンティティ
        let recipientEntity = NSEntityDescription()
        recipientEntity.name = "RecipientEntity"
        recipientEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let recipientAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .UUIDAttributeType, true),
            ("email", .stringAttributeType, true),
            ("name", .stringAttributeType, false),
            ("createdAt", .dateAttributeType, true),
            ("updatedAt", .dateAttributeType, true),
        ]
        recipientEntity.properties = recipientAttributes.map { name, type, required in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = !required
            return attr
        }

        // AppSettings エンティティ
        let settingsEntity = NSEntityDescription()
        settingsEntity.name = "AppSettingsEntity"
        settingsEntity.managedObjectClassName = NSStringFromClass(NSManagedObject.self)

        let settingsAttributes: [(String, NSAttributeType, Bool)] = [
            ("id", .UUIDAttributeType, true),
            ("key", .stringAttributeType, true),
            ("value", .stringAttributeType, true),
            ("updatedAt", .dateAttributeType, true),
        ]
        settingsEntity.properties = settingsAttributes.map { name, type, required in
            let attr = NSAttributeDescription()
            attr.name = name
            attr.attributeType = type
            attr.isOptional = !required
            return attr
        }

        model.entities = [historyEntity, recipientEntity, settingsEntity]

        let container = NSPersistentContainer(name: "SecureZip", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("インメモリ Core Data の初期化に失敗しました: \(error)")
            }
        }
        return container
    }
}
