import Foundation

protocol MServicePerformerProtocol {
    func recentPhotos(page: Int, perPage: Int) async throws -> Recent
}

struct MServicePerformer {
    private let configuration: MURLConfiguration

    init(configuration: MURLConfiguration) {
        self.configuration = configuration
    }

    var baseUrl: URL? {
        URL(string: configuration.baseUrl)
    }

    private var apiKey: String {
        configuration.apiKey
    }

    func makeRequest<T: Decodable>(_ request: MURLRequest,
                                   map: T.Type) async throws -> T {
        let (data, response) = try await configuration
            .service
            .performTask(with: request
                .appendQuery(name: MConstants.URL.Query.Keys.apiKey,
                             value: apiKey)
                .build())
        return try makeDecode(response: data, urlResponse: response, map: map)
    }

    private func makeDecode<T: Decodable>(response: Data,
                                          urlResponse: URLResponse,
                                          map: T.Type) throws -> T {

        let statusCode = urlResponse.httpResponse?.statusCode ?? MConstants.URL.statusCodeOk

        guard statusCode.inRange(MConstants.URL.statusCode2xx) else {
            throw MServiceError.generic(error: statusCode)
        }

        return try decode(response: response, map: map)
    }
    
    private func decode<T: Decodable>(response: Data,
                                      map: T.Type) throws -> T {
        try JSONDecoder().decode(map, from: response)
    }
}

private extension URLResponse {
    var httpResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }
}
