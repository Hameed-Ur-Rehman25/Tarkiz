import Foundation
import UserNotifications
import SwiftUI
import Combine

/// A simple manager to handle requesting user notification permissions.
class NotificationManager: ObservableObject {
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined

    init() {
        checkStatus()
    }

    /// Checks the current authorization status.
    func checkStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
            }
        }
    }

    /// Requests standard alert, sound, and badge permissions.
    func requestPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.checkStatus()
                completion(granted)
            }
        }
    }
}
