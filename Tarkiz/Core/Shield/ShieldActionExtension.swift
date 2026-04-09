import ManagedSettings
import DeviceActivity
import Foundation

// This extension handles actions taken on the shield (e.g., button clicks).
class ShieldActionExtension: ShieldActionDelegate {
    
    nonisolated override init() {
        super.init()
    }
    
    nonisolated override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Action for the "Dismiss" button
            completionHandler(.close)
            
        case .secondaryButtonPressed:
            // Action for the "Unlock via NFC" button
            completionHandler(.defer)
            
        @unknown default:
            completionHandler(.none)
        }
    }
}
