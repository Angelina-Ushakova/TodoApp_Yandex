import SwiftUI

class TodoItemViewModel: ObservableObject {
    @Published var todoItem: TodoItem
    @Published var selectedColor: Color
    
    init(todoItem: TodoItem) {
        self.todoItem = todoItem
        if let savedColor = UserDefaults.standard.string(forKey: "\(todoItem.id)_color") {
            self.selectedColor = Color(hex: savedColor)
        } else {
            self.selectedColor = Color.blue // начальный цвет по умолчанию
        }
    }
    
    func save() {
        saveColor()
        var items = loadItems()
        if let index = items.firstIndex(where: { $0.id == todoItem.id }) {
            items[index] = todoItem
        } else {
            items.append(todoItem)
        }
        saveItems(items)
    }
    
    func delete() {
        deleteColor()
        var items = loadItems()
        items.removeAll { $0.id == todoItem.id }
        saveItems(items)
    }
    
    func toggleDone() {
        todoItem.isDone.toggle()
        save()
    }
    
    private func loadItems() -> [TodoItem] {
        if let data = UserDefaults.standard.data(forKey: "todoItems") {
            if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [Any] {
                return jsonArray.compactMap { TodoItem.parse(json: $0) }
            }
        }
        return []
    }
    
    private func saveItems(_ items: [TodoItem]) {
        let jsonArray = items.map { $0.json }
        if let data = try? JSONSerialization.data(withJSONObject: jsonArray) {
            UserDefaults.standard.set(data, forKey: "todoItems")
        }
    }
    
    private func saveColor() {
        UserDefaults.standard.set(selectedColor.toHex(), forKey: "\(todoItem.id)_color")
    }
    
    private func deleteColor() {
        UserDefaults.standard.removeObject(forKey: "\(todoItem.id)_color")
    }
}
