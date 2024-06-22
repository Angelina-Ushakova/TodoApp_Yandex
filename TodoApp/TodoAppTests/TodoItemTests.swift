import XCTest
@testable import TodoApp

class TodoItemTests: XCTestCase {
    
    func testTodoItemInitialization() {
        let todoItem = TodoItem(id: "123", text: "Test Task", importance: .high, deadline: Date(), isDone: true, creationDate: Date(), modificationDate: Date())
        
        XCTAssertEqual(todoItem.id, "123")
        XCTAssertEqual(todoItem.text, "Test Task")
        XCTAssertEqual(todoItem.importance, .high)
        XCTAssertTrue(todoItem.isDone)
    }
    
    func testTodoItemJSONParsing() {
        let json: [String: Any] = [
            "id": "123",
            "text": "Test Task",
            "importance": "важная",
            "isDone": true,
            "creationDate": 1622548800.0,
            "deadline": 1622635200.0,
            "modificationDate": 1622721600.0
        ]
        
        guard let todoItem = TodoItem.parse(json: json) else {
            XCTFail("Parsing failed")
            return
        }
        
        XCTAssertEqual(todoItem.id, "123")
        XCTAssertEqual(todoItem.text, "Test Task")
        XCTAssertEqual(todoItem.importance, .high)
        XCTAssertTrue(todoItem.isDone)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970: 1622548800.0))
        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1622635200.0))
        XCTAssertEqual(todoItem.modificationDate, Date(timeIntervalSince1970: 1622721600.0))
    }
    
    func testTodoItemCSVParsing() {
        let csvLine = "123,\"Test Task\",\"важная\",true,1622548800,1622635200,1622721600"
        
        guard let todoItem = TodoItem.parseCSV(csvLine) else {
            XCTFail("CSV Parsing failed")
            return
        }
        
        XCTAssertEqual(todoItem.id, "123")
        XCTAssertEqual(todoItem.text, "Test Task")
        XCTAssertEqual(todoItem.importance, .high)
        XCTAssertTrue(todoItem.isDone)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970: 1622548800.0))
        XCTAssertEqual(todoItem.deadline, Date(timeIntervalSince1970: 1622635200.0))
        XCTAssertEqual(todoItem.modificationDate, Date(timeIntervalSince1970: 1622721600.0))
    }
    
    func testTodoItemToCSV() {
        let creationDate = Date(timeIntervalSince1970: 1622548800.0)
        let deadline = Date(timeIntervalSince1970: 1622635200.0)
        let modificationDate = Date(timeIntervalSince1970: 1622721600.0)
        
        let todoItem = TodoItem(id: "123", text: "Test Task", importance: .high, deadline: deadline, isDone: true, creationDate: creationDate, modificationDate: modificationDate)
        
        let csv = todoItem.csv
        let expectedCSV = "123,\"Test Task\",\"важная\",true,1622548800.0,1622635200.0,1622721600.0"
        
        XCTAssertEqual(csv, expectedCSV)
    }
    
    func testTodoItemOptionalFields() {
        let csvLineWithoutOptionalFields = "123,\"Test Task\",\"обычная\",true,1622548800,,"
        
        guard let todoItem = TodoItem.parseCSV(csvLineWithoutOptionalFields) else {
            XCTFail("CSV Parsing without optional fields failed")
            return
        }
        
        XCTAssertEqual(todoItem.id, "123")
        XCTAssertEqual(todoItem.text, "Test Task")
        XCTAssertEqual(todoItem.importance, .normal)
        XCTAssertTrue(todoItem.isDone)
        XCTAssertEqual(todoItem.creationDate, Date(timeIntervalSince1970: 1622548800.0))
        XCTAssertNil(todoItem.deadline)
        XCTAssertNil(todoItem.modificationDate)
    }
}
