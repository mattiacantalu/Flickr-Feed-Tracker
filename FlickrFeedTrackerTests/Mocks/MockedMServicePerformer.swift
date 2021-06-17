import Foundation
import UIKit
@testable import FlickrFeedTracker

class MockedMServicePerformer: MServicePerformerProtocol {
    var counterRecentPhoto: Int = 0
    var recentPhotoHandler: ((Int, Int) async throws -> Recent)?

    func recentPhotos(page: Int, perPage: Int) async throws -> Recent {
        counterRecentPhoto += 1
        if let recentPhotoHandler = recentPhotoHandler {
            return try await recentPhotoHandler(page, perPage)
        }
        return Recent(photo: .init(photos: []))
    }
}
