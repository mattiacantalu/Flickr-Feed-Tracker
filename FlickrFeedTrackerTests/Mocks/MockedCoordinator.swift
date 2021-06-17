import Foundation
import UIKit
@testable import FlickrFeedTracker

class MockedCoordinator: CoordinatorProtocol {
    var counterListController: Int = 0
    var counterAsRoot: Int = 0

    var listControllerHandler: (() -> UIViewController)?
    var asRootHandler: ((UIViewController) -> Void)?

    func listController() -> UIViewController {
        counterListController += 1
        if let listControllerHandler = listControllerHandler {
            return listControllerHandler()
        }
        return UIViewController()
    }

    func asRoot(controller: UIViewController) {
        counterAsRoot += 1
        if let asRootHandler = asRootHandler {
            asRootHandler(controller)
        }
    }
}
