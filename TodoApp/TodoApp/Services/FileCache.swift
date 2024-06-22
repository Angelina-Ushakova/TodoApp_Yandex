import Foundation

/// Класс для управления кэшированием задач в файлах
class FileCache {
    /// Коллекция задач, закрытая для внешнего изменения, но открытая для получения
    private(set) var items: [TodoItem] = []
    
    /// Функция добавления новой задачи
    /// - Parameter item: Задача, которую нужно добавить
    func addItem(_ item: TodoItem) {
        // Проверка на дублирование задач по id
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item  // Если задача с таким id уже существует, заменяем её
        } else {
            items.append(item)  // Если задачи с таким id нет, добавляем новую
        }
    }
    
    /// Функция удаления задачи на основе id
    /// - Parameter id: Уникальный идентификатор задачи, которую нужно удалить
    func removeItem(by id: String) {
        items.removeAll { $0.id == id }
    }
    
    /// Функция сохранения всех дел в файл
    /// - Parameter fileName: Имя файла, в который будут сохранены задачи
    func saveToFile(named fileName: String) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // Преобразование коллекции задач в JSON
            let data = try JSONSerialization.data(withJSONObject: items.map { $0.json })
            
            // Запись данных в файл
            try data.write(to: fileURL)
        } catch {
            print("Ошибка при сохранении данных: \(error)")
        }
    }
    
    /// Функция загрузки всех дел из файла
    /// - Parameter fileName: Имя файла, из которого будут загружены задачи
    func loadFromFile(named fileName: String) {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            // Чтение данных из файла
            let data = try Data(contentsOf: fileURL)
            
            // Преобразование данных в JSON
            if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [Any] {
                // Преобразование JSON в объекты TodoItem
                items = jsonArray.compactMap { TodoItem.parse(json: $0) }
            }
        } catch {
            print("Ошибка при загрузке данных: \(error)")
        }
    }
}
