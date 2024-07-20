import Foundation

protocol NetworkingService {
    // Получить список всех дел с ревизией
    func getTodoList() async throws -> (todos: [TodoItem], revision: Int)
    
    // Обновить список дел на сервере, используя ревизию
    func updateTodoList(_ list: [TodoItem], revision: Int) async throws -> [TodoItem]
    
    // Получить один элемент списка по ID с ревизией
    func getTodoItem(by id: String) async throws -> (item: TodoItem, revision: Int)
    
    // Добавить новый элемент в список
    func addTodoItem(_ item: TodoItem, revision: Int) async throws -> TodoItem
    
    // Обновить существующий элемент в списке
    func updateTodoItem(_ item: TodoItem, revision: Int) async throws -> TodoItem
    
    // Удалить элемент списка по ID
    func deleteTodoItem(by id: String, revision: Int) async throws -> TodoItem
}
