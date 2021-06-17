import XCTest
@testable import FlickrFeedTracker

class MImageDownloaderTests: XCTestCase {
    private var sut: MImageDownloader?
    private var cache: MockedCacheable?
    private var mockedImage: Data? {
        UIImage(named: "pokeball",
                in: Bundle(for: MImageDownloaderTests.self),
                with: .none)?
            .jpegData(compressionQuality: 1.0)
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        cache = MockedCacheable()

        let url = URL(string: "https://sampleurl.com")!
        let response = HTTPURLResponse(url: url)
        let session = MockedSession(data: try XCTUnwrap(mockedImage),
                                    response: try XCTUnwrap(response)) { _ in }
        let service = MURLService(session: try XCTUnwrap(session))
        
        sut = MImageDownloader(configuration: .init(service: service),
                               cache: try XCTUnwrap(cache))
    }

    func testDownloadImage_withCache_shouldReturnCachedImg() async throws {
        cache?.getHandler = {
            XCTAssertEqual($0, "https://sampleurl.com/sample/image")
            return self.mockedImage as AnyObject
        }

        let image = try await sut?.downloadImage(from: "sample/image")
        XCTAssertNotNil(image)
        XCTAssertEqual(image, mockedImage)
        XCTAssertEqual(cache?.counterGet, 1)
        XCTAssertEqual(cache?.counterSet, 0)
    }

    func testDownloadImage_withNocCache_shouldReturnNewImg() async throws {
        cache?.getHandler = {
            XCTAssertEqual($0, "https://sampleurl.com/sample/image")
            return nil
        }

        let image = try await sut?.downloadImage(from: "sample/image")
        XCTAssertNotNil(image)
        XCTAssertEqual(image, mockedImage)
        XCTAssertEqual(cache?.counterGet, 1)
        XCTAssertEqual(cache?.counterSet, 1)
    }

    func testDownloadImage_withBadData_shouldThrowError() async throws {
        cache?.getHandler = {
            XCTAssertEqual($0, "https://sampleurl.com/sample/image")
            return nil
        }

        let url = URL(string: "https://sampleurl.com")!
        let response = HTTPURLResponse(url: url, headerFields: [:])
        let session = MockedSession(data: try XCTUnwrap(mockedImage),
                                    response: try XCTUnwrap(response)) { _ in }
        let service = MURLService(session: try XCTUnwrap(session))
        
        sut = MImageDownloader(configuration: .init(service: service),
                               cache: try XCTUnwrap(cache))

        do {
            _ = try await sut?.downloadImage(from: "sample/image")
        } catch MServiceError.noImageData {}
        catch { XCTFail("Expected noData. Got \(error)!") }
    }
}

private extension MURLConfiguration {
    init(service: MURLService) {
        self.init(service: service,
                  baseUrl: "https://sampleurl.com",
                  apiKey: "")
    }
}

private extension HTTPURLResponse {
    convenience init?(url: URL,
                      headerFields: [String: String] = ["Content-Type": "image"]) {
        self.init(url: url,
                  statusCode: 200,
                  httpVersion: "1.0",
                  headerFields: headerFields)
    }
}
