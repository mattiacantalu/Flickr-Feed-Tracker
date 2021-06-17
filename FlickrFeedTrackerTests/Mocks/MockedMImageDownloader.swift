import Foundation
@testable import FlickrFeedTracker

class MockedMImageDownloader: MImageProtocol {
    var counterDownloadImage: Int = 0
    var downloadImageHandler: ((String) async throws -> Data)?

    func downloadImage(from link: String) async throws -> Data {
        counterDownloadImage += 1
        if let downloadImageHandler = downloadImageHandler {
            return try await downloadImageHandler(link)
        }
        return .init()
    }
}
