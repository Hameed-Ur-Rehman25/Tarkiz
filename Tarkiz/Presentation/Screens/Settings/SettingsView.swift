import SwiftUI
import Combine

// MARK: - SettingsViewModel

class SettingsViewModel: ObservableObject {
    @Published var strictMode = false
    let emergencyUnlocksRemaining = 5
    let userEmail = "user@example.com"
}

// MARK: - SettingsView

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Account
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Account")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                Text("Signed in as \(viewModel.userEmail)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appMutedForeground)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Share
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Share with a Friend")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.appForeground)
                                    Text("Your referral gets 10% off!")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appMutedForeground)
                                }
                                Button {
                                    // share action
                                } label: {
                                    Text("Refer a friend now")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appForeground)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color.appSecondary)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Emergency Unlock
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Emergency Unlock")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.appForeground)
                                    Text("\(viewModel.emergencyUnlocksRemaining) remaining")
                                        .font(.system(size: 14))
                                        .foregroundColor(.appMutedForeground)
                                }
                                Divider().background(Color.appBorder)
                                HStack {
                                    Text("Strict mode")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appForeground)
                                    Spacer()
                                    Toggle("", isOn: $viewModel.strictMode)
                                        .labelsHidden()
                                        .tint(.appPrimary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // About
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("About Tarkiz")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                    .padding(.bottom, 16)

                                SettingsRow(title: "Why Tarkiz?", showDivider: true) {}
                                SettingsRow(title: "Privacy Policy", showDivider: false) {}
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Prayer Settings
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Prayer Settings")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                    .padding(.bottom, 16)

                                SettingsRow(title: "Calculation Method", showDivider: true) {
                                    coordinator.navigate(to: .prayerSettings)
                                }
                                SettingsRow(title: "Blocked Apps", showDivider: true) {
                                    coordinator.navigate(to: .blocklist)
                                }
                                SettingsRow(title: "NFC Tag Setup", showDivider: false) {
                                    coordinator.navigate(to: .nfcPairing)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Questions
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 0) {
                                Text("Questions")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                    .padding(.bottom, 16)

                                SettingsRow(title: "Troubleshooting", showDivider: true) {}
                                SettingsRow(title: "Get Help", showDivider: true) {}
                                SettingsRow(title: "Delete account", showDivider: false) {}
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Sign Out
                        Button {
                            // sign out
                        } label: {
                            Text("Sign out")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appSecondary.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    .padding(.bottom, 32)
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 64)
            }
        }
    }
}

// MARK: - Reusable Settings Components

struct SettingsSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        content
            .padding(20)
            .background(Color.appSecondary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct SettingsRow: View {
    let title: String
    var showDivider: Bool = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                HStack {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.appForeground)
                    Spacer()
                    ChevronCircle()
                }
                .padding(.vertical, 12)

                if showDivider {
                    Divider().background(Color.appBorder)
                }
            }
        }
    }
}

struct ChevronCircle: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.appSecondary)
                .frame(width: 32, height: 32)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appMutedForeground)
        }
    }
}
