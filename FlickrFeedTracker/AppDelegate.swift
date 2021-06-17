import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let coordinator = AppCoordinator(window: window,
                                         configuration: FlickrFeedTrackerSession.configuration)
        coordinator.asRoot(controller: coordinator.listController())

        return true
    }
}

enum FlickrFeedTrackerSession {
    static var configuration = MURLConfiguration(service: MURLService(),
                                                 baseUrl: MConstants.URL.base,
                                                 apiKey: "")
    static var imgsConfiguration = MURLConfiguration(service: MURLService(),
                                                     baseUrl: MConstants.URL.imageBase,
                                                     apiKey: "")
}
