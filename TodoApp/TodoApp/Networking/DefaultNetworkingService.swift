import Foundation

final class DefaultNetworkingService: NetworkingService {
    private let baseURL = "https://beta.mrdekk.ru/todo"
    private let token = "Edrahil"
    
    private func makeRequest(url: URL, method: String, body: Data? = nil) async throws -> (Data, HTTPURLResponse) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkingError.unknownError
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return (data, httpResponse)
        case 400:
            throw NetworkingError.incorrectRequestFormat
        case 401:
            throw NetworkingError.incorrectAuthorization
        case 404:
            throw NetworkingError.elementNotFound
        case 409:
            throw NetworkingError.conflict
        case 500:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.unknownError
        }
    }
    
    func getTodoList() async throws -> (todos: [TodoItem], revision: Int) {
        let url = URL(string: "\(baseURL)/list")!
        let (data, _) = try await makeRequest(url: url, method: "GET")
        
        let response = try JSONDecoder().decode(GetTodoListResponse.self, from: data)
        return (todos: response.list, revision: response.revision)
    }
    
    func updateTodoList(_ list: [TodoItem], revision: Int) async throws -> [TodoItem] {
        let url = URL(string: "\(baseURL)/list")!
        var requestBody = list.map { $0.json }
        
        let body = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("X-Last-Known-Revision: \(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let (data, _) = try await makeRequest(url: url, method: "PATCH", body: body)
        
        let response = try JSONDecoder().decode(GetTodoListResponse.self, from: data)
        return response.list
    }
    
    func getTodoItem(by id: String) async throws -> (item: TodoItem, revision: Int) {
        let url = URL(string: "\(baseURL)/list/\(id)")!
        let (data, _) = try await makeRequest(url: url, method: "GET")
        
        let response = try JSONDecoder().decode(GetTodoItemResponse.self, from: data)
        return (item: response.element, revision: response.revision)
    }
    
    func addTodoItem(_ item: TodoItem, revision: Int) async throws -> TodoItem {
        let url = URL(string: "\(baseURL)/list")!
        let body = try JSONSerialization.data(withJSONObject: item.json, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("X-Last-Known-Revision: \(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let (data, _) = try await makeRequest(url: url, method: "POST", body: body)
        
        let response = try JSONDecoder().decode(GetTodoItemResponse.self, from: data)
        return response.element
    }
    
    func updateTodoItem(_ item: TodoItem, revision: Int) async throws -> TodoItem {
        let url = URL(string: "\(baseURL)/list/\(item.id)")!
        let body = try JSONSerialization.data(withJSONObject: item.json, options: [])
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("X-Last-Known-Revision: \(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let (data, _) = try await makeRequest(url: url, method: "PUT", body: body)
        
        let response = try JSONDecoder().decode(GetTodoItemResponse.self, from: data)
        return response.element
    }
    
    func deleteTodoItem(by id: String, revision: Int) async throws -> TodoItem {
        let url = URL(string: "\(baseURL)/list/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("X-Last-Known-Revision: \(revision)", forHTTPHeaderField: "X-Last-Known-Revision")
        
        let (data, _) = try await makeRequest(url: url, method: "DELETE")
        
        let response = try JSONDecoder().decode(GetTodoItemResponse.self, from: data)
        return response.element
    }
}


// Реактивные структуры для обработки ответов

struct GetTodoListResponse: Codable {
    let status: String
    let list: [TodoItem]
    let revision: Int
}

struct GetTodoItemResponse: Codable {
    let status: String
    let element: TodoItem
    let revision: Int
}
