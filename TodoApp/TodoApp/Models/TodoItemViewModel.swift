import SwiftUI
import SwiftData

class TodoItemViewModel: ObservableObject {
    @Published var todoItem: TodoItem
    @Published var selectedColor: Color

    private let fileCache = FileCache()

    init(todoItem: TodoItem) {
        self.todoItem = todoItem
        if let savedColor = UserDefaults.standard.string(forKey: "\(todoItem.id)_color") {
            self.selectedColor = Color(hex: savedColor)
        } else {
            self.selectedColor = Color.blue // начальный цвет по умолчанию
        }
    }
    
    @MainActor
    func save() {
        saveColor()
        fileCache.update(todoItem)
    }
    
    @MainActor
    func delete() {
        deleteColor()
        fileCache.delete(todoItem)
    }
    
    @MainActor
    func toggleDone() {
        todoItem.isDone.toggle()
        save()
    }

    private func saveColor() {
        UserDefaults.standard.set(selectedColor.toHex(), forKey: "\(todoItem.id)_color")
    }
    
    private func deleteColor() {
        UserDefaults.standard.removeObject(forKey: "\(todoItem.id)_color")
    }
}
