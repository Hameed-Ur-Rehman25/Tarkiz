import SwiftUI
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - AppItem Model (shared)

struct BlockedAppItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let category: String
    var blocked: Bool
}

// BlocklistView is now powered directly by ScreenTimeService

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
                        Text("\(screenTimeService.selection.applicationTokens.count + screenTimeService.selection.categoryTokens.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.appMutedForeground)
                            .frame(width: 40)
                    }
                    .padding(.top, 56)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    if screenTimeService.isAuthorized {
                        // Detailed Selection List
                        VStack(spacing: 20) {
                            HStack {
                                Text("Active Blocklist")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                                Text("\(screenTimeService.selection.applicationTokens.count + screenTimeService.selection.categoryTokens.count) Items")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.appMutedForeground)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.appSecondary)
                                    .clipShape(Capsule())
                            }
                            .padding(.horizontal, 4)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    if !screenTimeService.selection.categoryTokens.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("APP CATEGORIES")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.appMutedForeground)
                                                .tracking(1)
                                            
                                            ForEach(Array(screenTimeService.selection.categoryTokens), id: \.self) { token in
                                                TokenRowView(categoryToken: token)
                                            }
                                        }
                                        .padding(.bottom, 8)
                                    }
                                    
                                    if !screenTimeService.selection.applicationTokens.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("INDIVIDUAL APPS")
                                                .font(.system(size: 11, weight: .bold))
                                                .foregroundColor(.appMutedForeground)
                                                .tracking(1)
                                            
                                            ForEach(Array(screenTimeService.selection.applicationTokens), id: \.self) { token in
                                                TokenRowView(applicationToken: token)
                                            }
                                        }
                                    }
                                    
                                    if screenTimeService.selection.applicationTokens.isEmpty && screenTimeService.selection.categoryTokens.isEmpty {
                                        VStack(spacing: 16) {
                                            Image(systemName: "plus.app.fill")
                                                .font(.system(size: 40))
                                                .foregroundColor(.appMutedForeground.opacity(0.3))
                                            Text("No apps selected yet.\nTap below to start blocking.")
                                                .font(.system(size: 14))
                                                .foregroundColor(.appMutedForeground)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.vertical, 40)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(maxHeight: 300) // Keep it compact but scrollable
                            
                            Button {
                                isPickerPresented = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text(screenTimeService.selection.applicationTokens.isEmpty && screenTimeService.selection.categoryTokens.isEmpty ? "Select Apps to Block" : "Modify Selection")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(24)
                        .background(Color.appSecondary.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    } else {
                        // Authorization Request Card
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.appPrimary.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.appPrimary)
                            }
                            .padding(.top, 10)
                            
                            VStack(spacing: 12) {
                                Text("Permission Required")
                                    .font(.system(size: 20, weight: .bold))
                                
                                Text("Tarkiz needs permission to show the app selector and manage screen protection.")
                                    .font(.system(size: 14))
                                    .foregroundColor(.appMutedForeground)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            
                            Button {
                                Task {
                                    await screenTimeService.requestAuthorization()
                                }
                            } label: {
                                Text("Grant Permission")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.appPrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(.horizontal, 20)
                            
                            Text("If the permission dialog doesn't appear, please check Screen Time settings in your device Settings app.")
                                .font(.system(size: 12))
                                .foregroundColor(.appMutedForeground.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(24)
                        .background(Color.appSecondary.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                    
                    Spacer()
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.12), radius: 25, y: 15)
                .padding(.bottom, 24)
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTimeService.selection)
        .onChange(of: screenTimeService.selection) { _ in
            screenTimeService.applyShield()
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation { coordinator.isTabBarHidden = true }
        }
        .onDisappear {
            withAnimation { coordinator.isTabBarHidden = false }
        }
    }
}

// MARK: - Supporting Views

struct SelectionSummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(.appForeground)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appMutedForeground)
        }
    }
}

struct TokenRowView: View {
    var applicationToken: ApplicationToken?
    var categoryToken: ActivityCategoryToken?
    
    var body: some View {
        HStack {
            if let appToken = applicationToken {
                Label(appToken)
                    .font(.system(size: 15))
            } else if let catToken = categoryToken {
                Label(catToken)
                    .font(.system(size: 15))
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green.opacity(0.7))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(Color.appBackground.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
