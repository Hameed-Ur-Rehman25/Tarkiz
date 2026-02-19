import SwiftUI
import CoreLocation
import Combine

enum SetupStep {
    case welcome
    case location
    case calculation
    case blockApps
    case nfc
}

// Helper class to manage location delegate
class LocationManagerWrapper: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var location: CLLocation?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            location = manager.location
        }
    }
}

final class SetupViewModel: ObservableObject {
    @Published var currentStep: SetupStep = .welcome
    @Published var selectedLocation: String?
    @Published var locationPermissionStatus: CLAuthorizationStatus = .notDetermined
    
    private var locationWrapper = LocationManagerWrapper()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        locationWrapper.$authorizationStatus
            .assign(to: \.locationPermissionStatus, on: self)
            .store(in: &cancellables)
            
        locationWrapper.$location
            .compactMap { $0 }
            .sink { [weak self] _ in
                // Mock reverse geocoding
                self?.selectedLocation = "Current Location"
            }
            .store(in: &cancellables)
    }
    
    func nextStep() {
        switch currentStep {
        case .welcome: currentStep = .location
        case .location: currentStep = .calculation
        case .calculation: currentStep = .blockApps
        case .blockApps: currentStep = .nfc
        case .nfc: completeSetup()
        }
    }
    
    func previousStep() {
        switch currentStep {
        case .welcome: break
        case .location: currentStep = .welcome
        case .calculation: currentStep = .location
        case .blockApps: currentStep = .calculation
        case .nfc: currentStep = .blockApps
        }
    }
    
    func requestLocation() {
        locationWrapper.requestAuthorization()
    }
    
    func completeSetup() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
    
    func skip() {
        completeSetup()
    }
}
