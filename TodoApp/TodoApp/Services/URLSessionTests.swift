import XCTest
@testable import TodoApp

class URLSessionTests: XCTestCase {
    
    var session: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
    }
    
    override func tearDown() {
        session = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testGETRequest() async throws {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        let request = URLRequest(url: url)
        
        // Устанавливаем обработчик запроса для mock URL протокола
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = """
            {
                "userId": 1,
                "id": 1,
                "title": "delectus aut autem",
                "completed": false
            }
            """.data(using: .utf8)
            return (response, data)
        }
        
        do {
            let (data, response) = try await session.dataTask(for: request)
            XCTAssertNotNil(data)
            XCTAssertNotNil(response)
        } catch {
            XCTFail("Request failed with error: \(error)")
        }
    }
    
    func testCancelRequest() async {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        let request = URLRequest(url: url)
        
        // Устанавливаем обработчик запроса для mock URL протокола
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = """
            {
                "userId": 1,
                "id": 1,
                "title": "delectus aut autem",
                "completed": false
            }
            """.data(using: .utf8)
            return (response, data)
        }
        
        let task = Task {
            do {
                let (_, _) = try await session.dataTask(for: request)
                XCTFail("Request has not been cancelled")
            } catch is CancellationError {
                // Ожидаемое поведение
            } catch {
                XCTFail("Error: \(error)")
            }
        }
        task.cancel()
        await task.value
    }
}

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            fatalError("Request handler is not set.")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }

            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {
        // Не требуется дополнительных действий для остановки
    }
}
