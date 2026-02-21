import SwiftUI
import Combine

// MARK: - Data Models

struct PrayerMode: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let blockedApps: Int
    let categories: Int
}

// MARK: - HomeViewModel

class HomeViewModel: ObservableObject {
    @Published var isLocked = true
    @Published var selectedMode: PrayerMode
    @Published var modeSelectorOpen = false
    @Published var nfcSheetOpen = false
    @Published var protectedHours = 0
    @Published var protectedMinutes = 0

    let prayerModes: [PrayerMode] = [
        PrayerMode(id: "salah", name: "Salah Time", description: "Block during prayer windows", icon: "🕌", blockedApps: 12, categories: 3),
        PrayerMode(id: "focus", name: "Focus Mode", description: "Deep concentration", icon: "🎯", blockedApps: 8, categories: 2),
        PrayerMode(id: "quran", name: "Quran Time", description: "For recitation & study", icon: "📖", blockedApps: 15, categories: 4),
    ]

    init() {
        self.selectedMode = PrayerMode(id: "salah", name: "Salah Time", description: "Block during prayer windows", icon: "🕌", blockedApps: 12, categories: 3)
    }

    func toggleLock() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        isLocked.toggle()
    }
}

// MARK: - HomeView

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    // Time Badge
                    HStack(spacing: 6) {
                        Text("\(viewModel.protectedHours)h \(viewModel.protectedMinutes)m")
                            .font(.system(size: 18, weight: .semibold))
                            .monospacedDigit()
                            .foregroundColor(.appForeground)
                        Text("today")
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.appSecondary.opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.top, 32)

                    Spacer()

                    // Large NFC Icon
                    Image("NFCLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 176, height: 176)

                    // Mode selector button
                    Button {
                        viewModel.modeSelectorOpen = true
                    } label: {
                        HStack(spacing: 6) {
                            Text("Mode:")
                                .font(.system(size: 18))
                                .foregroundColor(.appMutedForeground)
                            Text(viewModel.selectedMode.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appForeground)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.appMutedForeground)
                        }
                    }
                    .padding(.top, 16)

                    Text("Blocking \(viewModel.selectedMode.blockedApps) apps, \(viewModel.selectedMode.categories) categories")
                        .font(.system(size: 14))
                        .foregroundColor(.appMutedForeground)
                        .padding(.top, 4)

                    Spacer()

                    // Action Button
                    Button {
                        viewModel.nfcSheetOpen = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.isLocked ? "lock.fill" : "lock.open.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.appForeground)
                            Text(viewModel.isLocked ? "Unlock with NFC" : "Start Protection")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.appForeground)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appSecondary.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 44)
            }
        }
        .sheet(isPresented: $viewModel.modeSelectorOpen) {
            ModeSelectorSheet(
                modes: viewModel.prayerModes,
                selectedMode: $viewModel.selectedMode,
                isPresented: $viewModel.modeSelectorOpen
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $viewModel.nfcSheetOpen) {
            NFCScanSheetView(
                isPresented: $viewModel.nfcSheetOpen,
                onSuccess: { viewModel.toggleLock() }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Mode Selector Sheet

struct ModeSelectorSheet: View {
    let modes: [PrayerMode]
    @Binding var selectedMode: PrayerMode
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Select Mode")
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 8)

            ForEach(modes) { mode in
                Button {
                    selectedMode = mode
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    isPresented = false
                } label: {
                    HStack(spacing: 16) {
                        Text(mode.icon)
                            .font(.system(size: 32))
                            .frame(width: 56, height: 56)
                            .background(Color.appSecondary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(mode.name)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.appForeground)
                            Text(mode.description)
                                .font(.system(size: 13))
                                .foregroundColor(.appMutedForeground)
                        }
                        Spacer()
                        if mode.id == selectedMode.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.appAccent)
                        }
                    }
                    .padding(16)
                    .background(
                        mode.id == selectedMode.id
                            ? Color.appAccent.opacity(0.08)
                            : Color.appSecondary.opacity(0.3)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color.appBackground.ignoresSafeArea())
    }
}

// MARK: - NFC Scan Sheet

struct NFCScanSheetView: View {
    @Binding var isPresented: Bool
    var onSuccess: () -> Void
    @State private var scanning = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Scan NFC Tag")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 8)

            ZStack {
                Circle()
                    .stroke(Color.appAccent.opacity(0.2), lineWidth: 3)
                    .frame(width: 120, height: 120)
                if scanning {
                    Circle()
                        .stroke(Color.appAccent.opacity(0.5), lineWidth: 3)
                        .frame(width: 120, height: 120)
                        .scaleEffect(1.4)
                        .opacity(0)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: scanning)
                }
                Image(systemName: "wave.3.right")
                    .font(.system(size: 40))
                    .foregroundColor(.appAccent)
            }

            Text("Hold your phone near the NFC tag")
                .font(.system(size: 14))
                .foregroundColor(.appMutedForeground)

            Button {
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                onSuccess()
                isPresented = false
            } label: {
                Text("Simulate Scan")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear { scanning = true }
    }
}
