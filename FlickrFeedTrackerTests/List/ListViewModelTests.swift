import XCTest
@testable import FlickrFeedTracker

class ListViewModelTest: XCTestCase {
    private var sut: ListViewModel?
    private var imageDownloader: MockedMImageDownloader?
    private var service: MockedMServicePerformer?
    private var coordinator: MockedCoordinator?
    private var fetchExpectation: XCTestExpectation?

    override func setUpWithError() throws {
        coordinator = MockedCoordinator()
        imageDownloader = MockedMImageDownloader()
        service = MockedMServicePerformer()
        sut = ListViewModel(service: try XCTUnwrap(service),
                            imageDownloader: try XCTUnwrap(imageDownloader))
        fetchExpectation = expectation(description: "Fetch should be set!")
    }
}

extension ListViewModelTest {
    @MainActor
    func testFetch_withSucceededService_shouldInsertItem() throws {
        service?.recentPhotoHandler = {
            XCTAssertEqual($0, 1)
            XCTAssertEqual($1, 1)
            return Recent.mock
        }

        XCTAssertEqual(sut?.viewModel.count, 0)

        sut?.fetch(success: {
            XCTAssertEqual($0.count, 1)
            XCTAssertNotNil($0.first)
            self.fetchExpectation?.fulfill()
        }, failure: { XCTFail("Expected success. Got \($0)") })
        wait(for: [try XCTUnwrap(fetchExpectation)], timeout: 5.0)

        XCTAssertEqual(service?.counterRecentPhoto, 1)
        XCTAssertEqual(sut?.viewModel.count, 1)
    }

    @MainActor
    func testFetch_withSucceededService_shouldNotInsertItem() throws {
        service?.recentPhotoHandler = { _, _ in
            Recent.init(photo: .init(photos: []))
        }

        XCTAssertEqual(sut?.viewModel.count, 0)

        sut?.fetch(success: {
            XCTAssertEqual($0.count, 0)
            XCTAssertNil($0.first)
            self.fetchExpectation?.fulfill()
        }, failure: { XCTFail("Expected success. Got \($0)") })
        wait(for: [try XCTUnwrap(fetchExpectation)], timeout: 5.0)

        XCTAssertEqual(service?.counterRecentPhoto, 1)
        XCTAssertEqual(sut?.viewModel.count, 0)
    }

    @MainActor
    func testFetch_withFailureService_shouldFail() throws {
        service?.recentPhotoHandler = {
            XCTAssertEqual($0, 1)
            XCTAssertEqual($1, 1)
            throw MockedSessionError.invalidResponse
        }

        sut?.fetch(success: { _ in XCTFail("Expected fail. Got success!") },
                   failure: {
            XCTAssertEqual($0 as? MockedSessionError, .invalidResponse)
            self.fetchExpectation?.fulfill()
        })
        wait(for: [try XCTUnwrap(fetchExpectation)], timeout: 5.0)

        XCTAssertEqual(service?.counterRecentPhoto, 1)
        XCTAssertEqual(sut?.viewModel.count, 0)
    }

}

private extension Recent {
    static var mock: Recent {
        Recent(photo: .init(photos: [.init(serverId: "123",
                                           id: "456",
                                           secret: "abc")]))
    }
}
