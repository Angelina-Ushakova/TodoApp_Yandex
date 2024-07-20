import Foundation

class TodoListSyncManager {
    private var todoItems: [TodoItem] = []
    private var isDirty: Bool = false
    private let networkingService: NetworkingService
    private var currentRevision: Int = 0

    init(networkingService: NetworkingService) {
        self.networkingService = networkingService
    }

    func addTodoItem(_ item: TodoItem) {
        if let index = todoItems.firstIndex(where: { $0.id == item.id }) {
            todoItems[index] = item
        } else {
            todoItems.append(item)
        }
        markAsDirty()
    }

    func removeTodoItem(by id: String) {
        todoItems.removeAll { $0.id == id }
        markAsDirty()
    }

    func markAsDirty() {
        isDirty = true
    }

    func clearDirtyFlag() {
        isDirty = false
    }

    func sync() async {
        guard isDirty else { return }

        do {
            let response = try await networkingService.updateTodoList(todoItems, revision: currentRevision)
            todoItems = response
            clearDirtyFlag()
        } catch {
            print("Ошибка синхронизации: \(error)")
        }
    }

    func setRevision(_ revision: Int) {
        currentRevision = revision
    }

    func getTodoItems() -> [TodoItem] {
        return todoItems
    }
}
