import Foundation
import CoreLocation
import SwiftUI
import Combine

/// A simple manager to handle requesting location permissions.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var fetchedCity: String?
    @Published var fetchedCountry: String?
    @Published var isFetching: Bool = false

    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    /// Requests "When In Use" location authorization and starts fetching location.
    func requestPermission() {
        isFetching = true
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
        }
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isFetching = false
                if let placemark = placemarks?.first {
                    self?.fetchedCity = placemark.locality ?? placemark.subAdministrativeArea ?? placemark.administrativeArea ?? "Unknown City"
                    self?.fetchedCountry = placemark.country ?? "Unknown Country"
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isFetching = false
        }
    }
}
