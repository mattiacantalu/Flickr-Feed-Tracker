import Foundation
import UIKit

protocol MImageProtocol {
    func downloadImage(from link: String) async throws -> Data
}

struct MImageDownloader {
    private let cache: MCacheable
    private let configuration: MURLConfiguration

    private var service: MURLService {
        configuration.service
    }

    private var baseUrl: String {
        configuration.baseUrl
    }

    init(configuration: MURLConfiguration,
         cache: MCacheable = DefaultCache()) {
        self.configuration = configuration
        self.cache = cache
    }

    func makeRequest(with url: URL) async throws -> Data {
        guard let cached = cache.object(for: url.absoluteString) as? Data else {
            return try await perform(url: url)
        }
        return cached
    }
}

private extension MImageDownloader {
    func perform(url: URL) async throws -> Data {
        let (data, response) = try await configuration.service.performTask(with: url)
        guard response.succeeded else { throw MServiceError.noImageData }
        cache.set(obj: data, for: url.absoluteString)
        return data
    }
}

extension MImageDownloader: MImageProtocol {
    func downloadImage(from link: String) async throws -> Data {
        guard let imageUrl = baseUrl.url?.appending(path: link) else {
            throw MServiceError.couldNotCreate(url: link)
        }
        return try await makeRequest(with: imageUrl)
    }
}

private extension String {
    var url: URL? {
        return [self]
            .compactMap({ URL(string: $0) })
            .first ?? nil
    }
}

private extension URLResponse {
    private var httpResponse: HTTPURLResponse? {
        self as? HTTPURLResponse
    }

    private var isImage: Bool {
        httpResponse?.mimeType?.hasPrefix("image") != nil
    }

    var succeeded: Bool {
        httpResponse?.statusCode == MConstants.URL.statusCodeOk
        && isImage
    }
}
