import Foundation

protocol MURLServiceProtocol {
    @MainActor func performTask(with request: URLRequest) async throws -> (Data, URLResponse)
    @MainActor func performTask(with url: URL) async throws -> (Data, URLResponse)
}

struct MURLService {
    private let session: MURLSessionProtocol

    init(session: MURLSessionProtocol = MURLSession()) {
        self.session = session
    }
}

extension MURLService: MURLServiceProtocol {
    @MainActor
    func performTask(with request: URLRequest) async throws -> (Data, URLResponse) {
        try await session.dataTask(with: request)
    }

    @MainActor
    func performTask(with url: URL) async throws -> (Data, URLResponse) {
        try await session.dataTask(with: url)
    }
}
