import SwiftUI
import Combine

// MARK: - AppItem Model (shared)

struct BlockedAppItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let category: String
    var blocked: Bool
}

// MARK: - BlocklistViewModel

class BlocklistViewModel: ObservableObject {
    @Published var apps: [BlockedAppItem] = [
        BlockedAppItem(id: "tiktok",    name: "TikTok",      icon: "🎵", category: "Social",        blocked: true),
        BlockedAppItem(id: "instagram", name: "Instagram",    icon: "📷", category: "Social",        blocked: true),
        BlockedAppItem(id: "facebook",  name: "Facebook",     icon: "👤", category: "Social",        blocked: true),
        BlockedAppItem(id: "twitter",   name: "X (Twitter)",  icon: "🐦", category: "Social",        blocked: false),
        BlockedAppItem(id: "youtube",   name: "YouTube",      icon: "▶️", category: "Entertainment", blocked: false),
        BlockedAppItem(id: "netflix",   name: "Netflix",      icon: "🎬", category: "Entertainment", blocked: false),
        BlockedAppItem(id: "reddit",    name: "Reddit",       icon: "🔴", category: "Social",        blocked: false),
        BlockedAppItem(id: "candy",     name: "Candy Crush",  icon: "🍬", category: "Games",         blocked: false),
    ]

    @Published var searchText = ""
    @Published var selectedCategory = "All"

    var availableCategories: [String] {
        ["All"] + Array(Set(apps.map(\.category))).sorted()
    }

    var filteredApps: [BlockedAppItem] {
        apps.filter { app in
            let matchesCategory = selectedCategory == "All" || app.category == selectedCategory
            let matchesSearch = searchText.isEmpty || app.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    var blockedCount: Int { apps.filter(\.blocked).count }

    func toggle(_ id: String) {
        Haptics.impact(.light)
        if let i = apps.firstIndex(where: { $0.id == id }) {
            apps[i].blocked.toggle()
        }
    }

    func blockAll() {
        Haptics.impact(.medium)
        for i in apps.indices { apps[i].blocked = true }
    }

    func unblockAll() {
        Haptics.impact(.medium)
        for i in apps.indices { apps[i].blocked = false }
    }
}

// MARK: - BlocklistView

struct BlocklistView: View {
    @StateObject private var screenTimeService = ScreenTimeService.shared
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var isPickerPresented = false

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button { coordinator.pop() } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.appSecondary)
                                    .frame(width: 40, height: 40)
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.appMutedForeground)
                            }
                        }
                        Spacer()
                        Text("Blocked Apps")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.appForeground)
                        Spacer()
                        Text("\(screenTimeService.selection.applications.count + screenTimeService.selection.categories.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appMutedForeground)
                            .frame(width: 40)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    // Selection Card
                    VStack(spacing: 20) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.appPrimary)
                        
                        Text("App Shielding is Active")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("Apps selected here will be blocked when focus mode is active.")
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            isPickerPresented = true
                        } label: {
                            Text("Modify Selection")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.appPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(24)
                    .background(Color.appSecondary.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    Spacer()
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 24)
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTimeService.selection)
        .onChange(of: screenTimeService.selection) { _ in
            screenTimeService.applyShield()
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Supporting Views

struct QuickActionButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appForeground)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.appSecondary.opacity(0.7))
                .clipShape(Capsule())
        }
    }
}

struct AppToggleRow: View {
    let app: BlockedAppItem
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appSecondary)
                        .frame(width: 48, height: 48)
                    Text(app.icon).font(.system(size: 24))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.appForeground)
                    Text(app.category)
                        .font(.system(size: 12))
                        .foregroundColor(.appMutedForeground)
                }
                Spacer()
                Image(systemName: app.blocked ? "minus.circle" : "plus.circle")
                    .font(.system(size: 22))
                    .foregroundColor(app.blocked ? .red.opacity(0.7) : .appMutedForeground)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
        }
    }
}
