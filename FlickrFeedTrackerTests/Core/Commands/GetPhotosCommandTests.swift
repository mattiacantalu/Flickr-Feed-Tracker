import XCTest
@testable import FlickrFeedTracker

extension MURLCommandTests {
    func testGetRecentPhotosRequest() async throws {
        let data = JSONMock.loadJson(fromResource: "valid_get_recent_photos")
        let session = MockedSession(data: try XCTUnwrap(data), response: .init()) {
            XCTAssertEqual($0.url?.absoluteString, "https://www.flickr.com/services/rest?method=flickr.photos.getRecent&per_page=1&page=1&format=json&nojsoncallback=1&api_key=123")
            XCTAssertEqual($0.httpMethod, "GET")
        }

        _ = try await MServicePerformer(configuration: configure(session))
            .recentPhotos(page: 1, perPage: 1)
    }

    func testGetRecentPhotosResponseShouldSuccess() async throws {
        let data = JSONMock.loadJson(fromResource: "valid_get_recent_photos")
        let session = MockedSession(data: try XCTUnwrap(data), response: .init()) { _ in }

        let recent = try await MServicePerformer(configuration: configure(session))
            .recentPhotos(page: 1, perPage: 1)
        XCTAssertEqual(recent.photo.photos.count, 1)
        XCTAssertEqual(recent.photo.photos.first?.id, "52914499467")
        XCTAssertEqual(recent.photo.photos.first?.secret, "60d1f65afa")
        XCTAssertEqual(recent.photo.photos.first?.serverId, "65535")
    }

    func testGetRecentPhotosResponse_withError_shouldFail() async throws {
        let session = try await MockedSession.simulate(failure: try XCTUnwrap(HTTPURLResponse.notFount()))
        do {
            _ = try await MServicePerformer(configuration: configure(session))
                .recentPhotos(page: 1, perPage: 1)
        } catch MServiceError.generic(error: let status) {
            XCTAssertEqual(status, 404)
        }
        catch { XCTFail("Expected badJson. Got \(error)") }
    }
}

private extension HTTPURLResponse {
    static func notFount() throws -> HTTPURLResponse? {
        HTTPURLResponse(url: try XCTUnwrap(URL(string: "www.sample.com")),
                        statusCode: 404,
                        httpVersion: nil,
                        headerFields: nil)
    }
}
