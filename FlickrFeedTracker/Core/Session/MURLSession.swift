import Foundation

protocol MURLSessionProtocol {
    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse)
    func dataTask(with url: URL) async throws -> (Data, URLResponse)
}

struct MURLSession: MURLSessionProtocol {
    private let session: URLSession

    init(urlSession: URLSession = URLSession.shared) {
        session = urlSession
    }

    func dataTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.data(for: request)
    }

    func dataTask(with url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}
