import Foundation

/// Расширение для структуры `TodoItem`, добавляющее функциональность работы с JSON
extension TodoItem {
    /// Функция для разбора JSON и создания объекта TodoItem
    /// - Parameter json: JSON-объект
    /// - Returns: Объект TodoItem, если разбор успешен, иначе nil
    static func parse(json: Any) -> TodoItem? {
        // Преобразуем входящий JSON в словарь [String: Any]
        guard let data = try? JSONSerialization.data(withJSONObject: json),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        // Извлекаем обязательные поля из словаря
        guard let id = dict["id"] as? String,
              let text = dict["text"] as? String,
              let isDone = dict["isDone"] as? Bool,
              let creationDateTimestamp = dict["creationDate"] as? TimeInterval else {
            return nil
        }
        
        // Преобразуем timestamp в дату
        let creationDate = Date(timeIntervalSince1970: creationDateTimestamp)
        
        // Извлекаем опциональные поля из словаря
        let importanceRaw = dict["importance"] as? String
        let importance = Importance(rawValue: importanceRaw ?? "обычная") ?? .normal
        
        let deadlineTimestamp = dict["deadline"] as? TimeInterval
        let deadline = deadlineTimestamp != nil ? Date(timeIntervalSince1970: deadlineTimestamp!) : nil
        let modificationDateTimestamp = dict["modificationDate"] as? TimeInterval
        let modificationDate = modificationDateTimestamp != nil ? Date(timeIntervalSince1970: modificationDateTimestamp!) : nil
        
        return TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            creationDate: creationDate,
            modificationDate: modificationDate
        )
    }
    
    /// Вычисляемое свойство для формирования JSON из объекта TodoItem
    var json: Any {
        // Создаем словарь для хранения значений
        var dict: [String: Any] = [
            "id": id,
            "text": text,
            "isDone": isDone,
            "creationDate": creationDate.timeIntervalSince1970
        ]
        
        // Сохраняем важность в словарь, если она не обычная
        if importance != .normal {
            dict["importance"] = importance.rawValue
        }
        
        // Сохраняем дедлайн в словарь, если он задан
        if let deadline = deadline {
            dict["deadline"] = deadline.timeIntervalSince1970
        }
        
        // Сохраняем дату изменения в словарь, если она задана
        if let modificationDate = modificationDate {
            dict["modificationDate"] = modificationDate.timeIntervalSince1970
        }
        
        // Возвращаем словарь в качестве JSON-объекта
        return dict
    }
}
