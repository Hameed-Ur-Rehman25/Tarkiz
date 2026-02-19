import SwiftUI

@main
struct TarkizApp: App {
    // Initialize CoreData stack on app launch
    let persistenceController = CoreDataStack.shared
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                LoginView()
                    .environment(\.managedObjectContext, persistenceController.viewContext)
            } else {
                SetupContainerView()
            }
        }
    }
}
