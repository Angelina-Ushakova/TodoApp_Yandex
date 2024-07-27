import Foundation
import SwiftData

@Model
final class TodoItemEntity {
    @Attribute(.unique) var id: String
    @Attribute var text: String
    @Attribute var importance: String
    @Attribute var deadline: Date?
    @Attribute var isDone: Bool
    @Attribute var creationDate: Date
    @Attribute var modificationDate: Date?
    @Attribute var files: [String]?
    
    init(id: String, text: String, importance: String, deadline: Date?, isDone: Bool, creationDate: Date, modificationDate: Date?, files: [String]?) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.files = files
    }
    
    // Пустой инициализатор необходим для SwiftData
    init() {
        self.id = UUID().uuidString
        self.text = ""
        self.importance = "обычная"
        self.deadline = nil
        self.isDone = false
        self.creationDate = Date()
        self.modificationDate = nil
        self.files = nil
    }
}

// Расширение FileCache для работы с SwiftData
extension FileCache {

    // Создаем модель контейнера для хранения данных
    private static var container: ModelContainer = {
        let container = try! ModelContainer(for: TodoItemEntity.self)
        return container
    }()
    
    @MainActor
    private var context: ModelContext {
        return FileCache.container.mainContext
    }

    @MainActor
    func insert(_ todoItem: TodoItem) {
        let entity = TodoItemEntity(id: todoItem.id, text: todoItem.text, importance: todoItem.importance.rawValue, deadline: todoItem.deadline, isDone: todoItem.isDone, creationDate: todoItem.creationDate, modificationDate: todoItem.modificationDate, files: todoItem.files)
        context.insert(entity)
        saveContext()
    }

    @MainActor
    func fetch() -> [TodoItem] {
        let fetchRequest = FetchDescriptor<TodoItemEntity>()
        do {
            let result = try context.fetch(fetchRequest)
            return result.map { entity in
                TodoItem(
                    id: entity.id,
                    text: entity.text,
                    importance: Importance(rawValue: entity.importance) ?? .normal,
                    deadline: entity.deadline,
                    isDone: entity.isDone,
                    creationDate: entity.creationDate,
                    modificationDate: entity.modificationDate,
                    files: entity.files
                )
            }
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }

    @MainActor
    func delete(_ todoItem: TodoItem) {
        let fetchRequest = FetchDescriptor<TodoItemEntity>(predicate: #Predicate { $0.id == todoItem.id })
        do {
            let result = try context.fetch(fetchRequest)
            for entity in result {
                context.delete(entity)
            }
            saveContext()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }

    @MainActor
    func update(_ todoItem: TodoItem) {
        let fetchRequest = FetchDescriptor<TodoItemEntity>(predicate: #Predicate { $0.id == todoItem.id })
        do {
            let result = try context.fetch(fetchRequest)
            if let entity = result.first {
                entity.text = todoItem.text
                entity.importance = todoItem.importance.rawValue
                entity.deadline = todoItem.deadline
                entity.isDone = todoItem.isDone
                entity.creationDate = todoItem.creationDate
                entity.modificationDate = todoItem.modificationDate
                entity.files = todoItem.files
                saveContext()
            }
        } catch {
            print("Failed to update item: \(error)")
        }
    }

    @MainActor
    func fetch(predicate: Predicate<TodoItemEntity>?, sortDescriptors: [SortDescriptor<TodoItemEntity>]) -> [TodoItem] {
        var fetchRequest = FetchDescriptor<TodoItemEntity>()
        fetchRequest.predicate = predicate
        fetchRequest.sortBy = sortDescriptors
        do {
            let result = try context.fetch(fetchRequest)
            return result.map { entity in
                TodoItem(
                    id: entity.id,
                    text: entity.text,
                    importance: Importance(rawValue: entity.importance) ?? .normal,
                    deadline: entity.deadline,
                    isDone: entity.isDone,
                    creationDate: entity.creationDate,
                    modificationDate: entity.modificationDate,
                    files: entity.files
                )
            }
        } catch {
            print("Failed to fetch items: \(error)")
            return []
        }
    }

    @MainActor
    private func saveContext() {
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
