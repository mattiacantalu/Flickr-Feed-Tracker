import Foundation
import UIKit

protocol CoordinatorProtocol {
    func listController() -> UIViewController
    func asRoot(controller: UIViewController)
}

class AppCoordinator: CoordinatorProtocol {
    private let configuration: MURLConfiguration
    private let window: UIWindow?

    init(window: UIWindow?,
         configuration: MURLConfiguration) {
        self.window = window
        self.configuration = configuration
    }

    func listController() -> UIViewController {
        let imageDownloader = MImageDownloader(configuration: FlickrFeedTrackerSession.imgsConfiguration,
                                               cache: MCacheService())
        let service = MServicePerformer(configuration: configuration)
        let viewModel = ListViewModel(service: service,
                                      imageDownloader: imageDownloader)
        let locationService = LocationService()
        let locationModel = LocationViewModel(service: locationService)
        locationService.setViewModel(locationModel)
        let controller = ListViewController(viewModel: viewModel,
                                            locationModel: locationModel)
        return UINavigationController(rootViewController: controller)
    }

    func asRoot(controller: UIViewController) {
        window?.rootViewController = controller
    }
}
