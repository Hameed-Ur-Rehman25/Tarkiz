import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()
    
    @Published var selection = FamilyActivitySelection()
    private let store = ManagedSettingsStore()
    
    private init() {}
    
    func requestAuthorization() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }
    
    func applyShield() {
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        if applications.isEmpty && categories.isEmpty {
            store.shield.applications = nil
        } else {
            store.shield.applications = applications
            store.shield.applicationCategories = .specific(categories)
        }
    }
    
    func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
}
