import SwiftUI

// MARK: - RootView (Decides onboarding vs. main)

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        ZStack {
            if coordinator.hasCompletedOnboarding {
                MainTabView()
                    .environmentObject(coordinator)
                    .transition(.opacity)

                // Lock screen overlay
                if coordinator.isLocked {
                    LockScreenView { coordinator.dismissLockScreen() }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .zIndex(10)
                }
            } else {
                OnboardingFlow {
                    coordinator.completeOnboarding()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: coordinator.hasCompletedOnboarding)
        .animation(.easeInOut(duration: 0.4), value: coordinator.isLocked)
        .onAppear {
            coordinator.hasCompletedOnboarding =
                UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
    }
}

// MARK: - MainTabView

struct MainTabView: View {
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            NavigationStack(path: $coordinator.navigationPath) {
                HomeView()
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Home",    systemImage: "house.fill") }
            .tag(MainTab.home)

            NavigationStack {
                PrayerTimesView()
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Prayer",  systemImage: "moon.stars.fill") }
            .tag(MainTab.prayer)

            NavigationStack {
                StatsView()
                    .navigationBarHidden(true)
            }
            .tabItem { Label("Stats",   systemImage: "chart.bar.fill") }
            .tag(MainTab.stats)

            NavigationStack(path: $coordinator.navigationPath) {
                SettingsView()
                    .navigationBarHidden(true)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .blocklist:      BlocklistView()
                        case .nfcPairing:     NFCPairingView()
                        case .prayerSettings: PrayerSettingsView()
                        default:              EmptyView()
                        }
                    }
            }
            .environmentObject(coordinator)
            .tabItem { Label("Settings", systemImage: "gear") }
            .tag(MainTab.settings)
        }
        .tint(.appPrimary)
    }
}
