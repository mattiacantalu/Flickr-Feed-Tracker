import XCTest
@testable import FlickrFeedTracker

class MURLRequestTests: XCTestCase {
    func testCreateRequest() throws {
        let url = URL(string: "https://www.flickr.com/services")
        let request = MURLRequest
            .get(url: try XCTUnwrap(url))
            .with(component: "rest")
            .appendQuery(name: "method", value: "getRecent")
        XCTAssertEqual(request.url.absoluteString, "https://www.flickr.com/services/rest?method=getRecent")
        XCTAssertEqual(request.method.rawValue, "GET")
    }
}
