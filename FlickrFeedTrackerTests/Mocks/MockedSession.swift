import Foundation
@testable import FlickrFeedTracker

struct MockedSession: MURLSessionProtocol {
    let data: Data
    private(set) var response: URLResponse
    let completionRequest: (URLRequest) -> Void

    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        completionRequest(request)
        return (data, response)
    }

    func dataTask(with url: URL) async throws -> (Data, URLResponse) {
        (data, response)
    }

    static func simulate(failure response: URLResponse) async throws -> MURLSessionProtocol {
        MockedSession(data: .init(), response: response) { _ in }
    }

    static func simulate(failure data: Data) async throws -> MURLSessionProtocol {
        MockedSession(data: data, response: .init()) { _ in }
    }
}

enum MockedSessionError: Error {
    case badURL
    case badJSON
    case invalidResponse
}
