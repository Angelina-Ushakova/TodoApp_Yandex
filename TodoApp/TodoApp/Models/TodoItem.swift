import Foundation

/// Структура, представляющая элемент задачи (TodoItem)
struct TodoItem {
    /// Уникальный идентификатор задачи
    let id: String
    /// Текст задачи
    let text: String
    /// Важность задачи (неважная, обычная, важная)
    let importance: Importance
    /// Дедлайн задачи (может быть не задан)
    let deadline: Date?
    /// Флаг выполнения задачи
    let isDone: Bool
    /// Дата создания задачи
    let creationDate: Date
    /// Дата изменения задачи (опционально)
    let modificationDate: Date?
    
    /// Инициализатор для создания нового элемента задачи
    /// - Parameters:
    ///   - id: Уникальный идентификатор (если не задан, генерируется автоматически)
    ///   - text: Текст задачи
    ///   - importance: Важность задачи (по умолчанию — обычная)
    ///   - deadline: Дедлайн задачи (по умолчанию — nil)
    ///   - isDone: Флаг выполнения задачи (по умолчанию — false)
    ///   - creationDate: Дата создания задачи (по умолчанию — текущая дата)
    ///   - modificationDate: Дата изменения задачи (по умолчанию — nil)
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
enum Importance: String {
    /// Неважная задача
    case low = "неважная"
    /// Обычная задача
    case normal = "обычная"
    /// Важная задача
    case high = "важная"
}
