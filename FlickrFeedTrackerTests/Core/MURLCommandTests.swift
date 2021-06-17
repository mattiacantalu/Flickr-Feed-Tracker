import XCTest
@testable import FlickrFeedTracker

class MURLCommandTests: XCTestCase {
    override func setUp() {}

    func configure(_ session: MURLSessionProtocol) -> MURLConfiguration {
        let service = MURLService(session: session)
        return MURLConfiguration(service: service,
                                 baseUrl: "https://www.flickr.com/services/rest",
                                 apiKey: "123")
    }
}
