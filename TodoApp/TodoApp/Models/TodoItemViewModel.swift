import SwiftUI

class TodoItemViewModel: ObservableObject {
    @Published var todoItem: TodoItem
    
    init(todoItem: TodoItem) {
        self.todoItem = todoItem
    }
    
    func save() {
        var items = loadItems()
        if let index = items.firstIndex(where: { $0.id == todoItem.id }) {
            items[index] = todoItem
        } else {
            items.append(todoItem)
        }
        saveItems(items)
    }
    
    func delete() {
        var items = loadItems()
        items.removeAll { $0.id == todoItem.id }
        saveItems(items)
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
}
