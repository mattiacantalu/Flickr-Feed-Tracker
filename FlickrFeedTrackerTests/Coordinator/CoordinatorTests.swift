import XCTest
@testable import FlickrFeedTracker

class CoordinatorTests: XCTestCase {
    var sut: AppCoordinator?

    override func setUp() {
        sut = AppCoordinator(window: nil,
                             configuration: MURLConfiguration(service: MURLService(),
                                                              baseUrl: "base_url",
                                                              apiKey: "apiKey"))
    }

    func testController_shouldBe_ListController() throws {
        let controller = sut?.listController() as? UINavigationController
        XCTAssertTrue(controller?.viewControllers.first is ListViewController)
    }

    func testController_shoulBe_setAsRoot() {
        let window = UIWindow()
        sut = AppCoordinator(window: window,
                             configuration: MURLConfiguration(service: MURLService(),
                                                              baseUrl: "base_url",
                                                              apiKey: "apiKey"))
        let controller = UIViewController()
        sut?.asRoot(controller: controller)

        XCTAssertEqual(window.rootViewController, controller)
    }
}
