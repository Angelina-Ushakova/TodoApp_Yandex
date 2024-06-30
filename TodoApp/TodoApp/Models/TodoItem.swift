import Foundation

/// Структура, представляющая элемент задачи (TodoItem)
struct TodoItem: Identifiable {
    /// Уникальный идентификатор задачи
    let id: String
    /// Текст задачи
    var text: String
    /// Важность задачи (неважная, обычная, важная)
    var importance: Importance
    /// Дедлайн задачи (может быть не задан)
    var deadline: Date?
    /// Флаг выполнения задачи
    var isDone: Bool
    /// Дата создания задачи
    var creationDate: Date
    /// Дата изменения задачи (опционально)
    var modificationDate: Date?
    
    
    /// Инициализатор для создания нового элемента задачи
    init(id: String = UUID().uuidString, text: String, importance: Importance = .normal, deadline: Date? = nil, isDone: Bool = false, creationDate: Date = Date(), modificationDate: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.creationDate = creationDate
        self.modificationDate = modificationDate
    }
}

/// Перечисление, представляющее важность задачи
enum Importance: String, CaseIterable, Codable {
    case low = "неважная"
    case normal = "обычная"
    case high = "важная"
}
