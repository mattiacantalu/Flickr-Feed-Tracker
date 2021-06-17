import CoreLocation
import Foundation
@testable import FlickrFeedTracker

class MockedLocationService: LocationProvider {
    var counterRequestAlwaysAuthorization: Int = 0
    var counterStartUpdatingLocation: Int = 0
    var counterAuthorization: Int = 0

    var requestAlwaysAuthorizationHandler: (() -> Void)?
    var startUpdatingLocationHandler: (() -> Void)?

    public init() {}

    func requestAlwaysAuthorization() {
        counterRequestAlwaysAuthorization += 1
        if let requestAlwaysAuthorizationHandler = requestAlwaysAuthorizationHandler {
            return requestAlwaysAuthorizationHandler()
        }
    }

    func startUpdatingLocation() {
        counterStartUpdatingLocation += 1
        if let startUpdatingLocationHandler = startUpdatingLocationHandler {
            return startUpdatingLocationHandler()
        }
    }

    var authorization: CLAuthorizationStatus = .notDetermined {
        didSet { counterAuthorization += 1 }
    }
}
