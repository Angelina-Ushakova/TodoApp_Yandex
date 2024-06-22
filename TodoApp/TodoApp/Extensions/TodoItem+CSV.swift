import Foundation

/// Расширение для структуры `TodoItem`, добавляющее функциональность работы с CSV
extension TodoItem {
    /// Функция для разбора строки CSV и создания объекта TodoItem
    /// - Parameter csv: Строка CSV
    /// - Returns: Объект TodoItem, если разбор успешен, иначе nil
    static func parseCSV(_ csv: String) -> TodoItem? {
        let components = parseCSVLine(csv)
        guard components.count == 7 else {
            return nil
        }
        
        guard let id = components[0] as String?,
              let text = components[1] as String?,
              let importance = Importance(rawValue: components[2]),
              let isDone = Bool(components[3]),
              let creationDate = TimeInterval(components[4]).flatMap({ Date(timeIntervalSince1970: $0) }) else {
            return nil
        }
        
        let deadline = components[5].isEmpty ? nil : TimeInterval(components[5]).flatMap({ Date(timeIntervalSince1970: $0) })
        let modificationDate = components[6].isEmpty ? nil : TimeInterval(components[6]).flatMap({ Date(timeIntervalSince1970: $0) })
        
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
    
    /// Вычисляемое свойство для формирования строки CSV из объекта TodoItem
    var csv: String {
        let components: [String] = [
            id,
            escapeCSV(text),
            escapeCSV(importance.rawValue),
            "\(isDone)",
            "\(creationDate.timeIntervalSince1970)",
            deadline != nil ? "\(deadline!.timeIntervalSince1970)" : "",
            modificationDate != nil ? "\(modificationDate!.timeIntervalSince1970)" : ""
        ]
        
        return components.joined(separator: ",")
    }
    
    /// Вспомогательная функция для обработки строки CSV и разделения её на компоненты
    /// - Parameter csvLine: Строка CSV
    /// - Returns: Массив компонентов строки
    private static func parseCSVLine(_ csvLine: String) -> [String] {
        var components: [String] = []
        var currentComponent = ""
        var inQuotes = false
        
        for character in csvLine {
            if character == "\"" {
                inQuotes.toggle()
            } else if character == "," && !inQuotes {
                components.append(currentComponent)
                currentComponent = ""
            } else {
                currentComponent.append(character)
            }
        }
        components.append(currentComponent)
        
        return components.map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    /// Вспомогательная функция для экранирования текста
    /// - Parameter text: Текст для экранирования
    /// - Returns: Экранированный текст
    private func escapeCSV(_ text: String) -> String {
        var escapedText = text.replacingOccurrences(of: "\"", with: "\"\"")
        escapedText = "\"\(escapedText)\""
        return escapedText
    }
}
