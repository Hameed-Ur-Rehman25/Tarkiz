import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity
import Combine

class ScreenTimeService: ObservableObject {
    static let shared = ScreenTimeService()
    
    @Published var selection = FamilyActivitySelection() {
        didSet {
            // Automatically save and apply shield when selection changes
            saveSelection()
            applyShield()
        }
    }
    
    @Published var isAuthorized = false
    private let store = ManagedSettingsStore()
    private let selectionKey = "screenTimeSelection"
    
    private init() {
        checkAuthorization()
        loadSelection()
    }
    
    private func checkAuthorization() {
        // Simple check: if we have a selection or have asked before, we might be authorized.
        // But the official way is to check the center
        // Note: isAuthorized can be refined based on specific needs.
        self.isAuthorized = AuthorizationCenter.shared.authorizationStatus == .approved
    }
    
    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            DispatchQueue.main.async {
                self.isAuthorized = true
                print("Screen Time authorized successfully")
            }
        } catch {
            print("Failed to authorize Screen Time: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    func applyShield() {
        let applications = selection.applicationTokens
        let categories = selection.categoryTokens
        
        if applications.isEmpty && categories.isEmpty {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
        } else {
            // Apply shields to specific applications and categories
            store.shield.applications = applications
            store.shield.applicationCategories = .specific(categories)
            print("Shields applied to \(applications.count) apps and \(categories.count) categories.")
        }
    }
    
    func removeShield() {
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        print("All shields removed.")
    }
    
    private func saveSelection() {
        do {
            let data = try JSONEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: selectionKey)
        } catch {
            print("Failed to save selection: \(error.localizedDescription)")
        }
    }
    
    private func loadSelection() {
        guard let data = UserDefaults.standard.data(forKey: selectionKey) else { return }
        do {
            let savedSelection = try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            self.selection = savedSelection
        } catch {
            print("Failed to load selection: \(error.localizedDescription)")
        }
    }
}
