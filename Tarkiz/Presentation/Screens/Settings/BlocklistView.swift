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
    @StateObject private var viewModel = BlocklistViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

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
                        Text("\(viewModel.blockedCount)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appMutedForeground)
                            .frame(width: 40)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Quick Actions
                    HStack(spacing: 8) {
                        QuickActionButton(title: "Block All") { viewModel.blockAll() }
                        QuickActionButton(title: "Unblock All") { viewModel.unblockAll() }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    // Search
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.appMutedForeground)
                        TextField("Search apps...", text: $viewModel.searchText)
                            .font(.system(size: 15))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.appSecondary.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // Category Filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.availableCategories, id: \.self) { cat in
                                Button { viewModel.selectedCategory = cat } label: {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(viewModel.selectedCategory == cat ? .white : .appMutedForeground)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(viewModel.selectedCategory == cat ? Color.appPrimary : Color.appSecondary.opacity(0.5))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 12)

                    // App List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.filteredApps.enumerated()), id: \.element.id) { idx, app in
                                AppToggleRow(app: app) { viewModel.toggle(app.id) }
                                if idx < viewModel.filteredApps.count - 1 {
                                    Divider().background(Color.appBorder).padding(.leading, 74)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 24)
            }
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
