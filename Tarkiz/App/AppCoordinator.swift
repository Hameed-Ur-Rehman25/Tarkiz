import SwiftUI
import Combine


// MARK: - Route Definitions

enum AppRoute: Hashable {
    case home
    case prayerTimes
    case stats
    case settings
    case blocklist
    case nfcPairing
    case prayerSettings
    case lockScreen
}

enum MainTab: Int, CaseIterable {
    case home, prayer, stats, settings

    var label: String {
        switch self {
        case .home: return "Home"
        case .prayer: return "Prayer"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }
}

// MARK: - App Coordinator

class AppCoordinator: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isLocked = false
    @Published var selectedTab: MainTab = .home
    @Published var navigationPath = NavigationPath()

    func completeOnboarding() {
        withAnimation(.easeInOut(duration: 0.4)) {
            hasCompletedOnboarding = true
        }
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }

    func showLockScreen() {
        withAnimation { isLocked = true }
    }

    func dismissLockScreen() {
        withAnimation { isLocked = false }
    }

    func navigate(to route: AppRoute) {
        switch route {
        case .home:           selectedTab = .home; navigationPath = NavigationPath()
        case .prayerTimes:    selectedTab = .prayer; navigationPath = NavigationPath()
        case .stats:          selectedTab = .stats; navigationPath = NavigationPath()
        case .settings:       selectedTab = .settings; navigationPath = NavigationPath()
        case .blocklist:      selectedTab = .settings; navigationPath.append(route)
        case .nfcPairing:     selectedTab = .settings; navigationPath.append(route)
        case .prayerSettings: selectedTab = .settings; navigationPath.append(route)
        case .lockScreen:     showLockScreen()
        }
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
}
