import CoreLocation
import MapKit
import Foundation

protocol LocationProvider {
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    var authorization: CLAuthorizationStatus { get }
}

protocol LocationViewModelDelegate: AnyObject {
    func locationService(_ location: CLLocation?, didUpdateLocations locations: [CLLocation])
    func locationServiceDidChangeAuthorization(_ authorization: CLAuthorizationStatus)
}

class LocationService: NSObject, LocationProvider, CLLocationManagerDelegate {
    private let service: CLLocationManager
    private weak var viewModel: LocationViewModelDelegate?

    override init() {
        service = CLLocationManager()
        super.init()
        service.delegate = self
        service.allowsBackgroundLocationUpdates = true
    }

    var authorization: CLAuthorizationStatus {
        service.authorizationStatus
    }

    func setViewModel(_ delegate: LocationViewModelDelegate) {
        viewModel = delegate
    }

    func requestAlwaysAuthorization() {
        service.desiredAccuracy = kCLLocationAccuracyBest
        service.requestAlwaysAuthorization()
    }

    func startUpdatingLocation() {
        service.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        viewModel?.locationService(manager.location, didUpdateLocations: locations)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        viewModel?.locationServiceDidChangeAuthorization(manager.authorizationStatus)
    }
}
