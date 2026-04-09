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
    case calculationMethod
    case lockScreen
}

// ... MainTab enum unchanged ...

// MARK: - App Coordinator

class AppCoordinator: ObservableObject {
    @Published var hasCompletedOnboarding = false
    @Published var isLocked = false
    @Published var selectedTab: MainTab = .home
    @Published var isTabBarHidden: Bool = false
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
        case .home:           selectedTab = .home; navigationPath = NavigationPath(); isTabBarHidden = false
        case .prayerTimes:    selectedTab = .prayer; navigationPath = NavigationPath(); isTabBarHidden = false
        case .stats:          selectedTab = .stats; navigationPath = NavigationPath(); isTabBarHidden = false
        case .settings:       selectedTab = .settings; navigationPath = NavigationPath(); isTabBarHidden = false
        case .blocklist:      selectedTab = .settings; navigationPath.append(route); isTabBarHidden = true
        case .nfcPairing:     selectedTab = .settings; navigationPath.append(route); isTabBarHidden = true
        case .prayerSettings: selectedTab = .settings; navigationPath.append(route); isTabBarHidden = true
        case .calculationMethod: selectedTab = .settings; navigationPath.append(route); isTabBarHidden = true
        case .lockScreen:     showLockScreen()
        }
    }

    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
        
        // Return tab bar if we are at the root
        if navigationPath.isEmpty {
            isTabBarHidden = false
        }
    }
}
