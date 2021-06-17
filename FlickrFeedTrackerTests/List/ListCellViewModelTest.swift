import XCTest
@testable import FlickrFeedTracker

class ListCellViewModelTest: XCTestCase {
    private var sut: ListCellViewModel?
    private var service: MockedMImageDownloader?
    private var mockedImage: Data {
        UIImage(named: "pokeball",
                in: Bundle(for: MImageDownloaderTests.self),
                with: .none)?
            .jpegData(compressionQuality: 1.0) ?? .init()
    }

    override func setUpWithError() throws{
        service = MockedMImageDownloader()
        sut = ListCellViewModel(service: try XCTUnwrap(service),
                                photoModel: Photo(serverId: "123",
                                                 id: "456",
                                                 secret: "abc"))
    }

    func testFetchImage_withCorrectUrl_shouldDownloadImage() async throws {
        service?.downloadImageHandler = { link in
            XCTAssertEqual(link, "123/456_abc.jpg")
            return self.mockedImage
        }

        let image = try await sut?.fetchImage()
        XCTAssertNotNil(image)
        XCTAssertEqual(image, mockedImage)
        XCTAssertEqual(service?.counterDownloadImage, 1)
    }
    
    func testFetchImage_withError_shouldFailure() async {
        service?.downloadImageHandler = { _ in
            throw MServiceError.couldNotCreate(url: "www.sampl.url")
        }

        do {
            _ = try await sut?.fetchImage()
        } catch MServiceError.couldNotCreate(url: let url) {
            XCTAssertEqual(url, "www.sampl.url")
            XCTAssertEqual(self.service?.counterDownloadImage, 1)
        } catch { XCTFail("Expected couldNotCreateUrl. Got \(error)!") }
        
    }
}
