import SwiftUI
import Combine
import FamilyControls

// MARK: - HomeViewModel

class HomeViewModel: ObservableObject {
    @Published var isLocked = false
    @Published var nfcSheetOpen = false
    @Published var protectedHours = 0
    @Published var protectedMinutes = 0

    func toggleLock() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        isLocked.toggle()
    }
}

// MARK: - HomeView

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var screenTimeService = ScreenTimeService.shared

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
                        .padding(.top, 20)

                    // Real-time Protection Counts
                    VStack(spacing: 4) {
                        Text("\(screenTimeService.selection.applicationTokens.count) Apps, \(screenTimeService.selection.categoryTokens.count) Categories")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.appForeground)
                        Text("Total Protected Items")
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)
                            .tracking(0.5)
                    }
                    .padding(.top, 24)

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
                    .padding(.bottom, 48)
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 120)
            }
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

// MARK: - NFC Scan Sheet

struct NFCScanSheetView: View {
    @Binding var isPresented: Bool
    var onSuccess: () -> Void
    
    @StateObject private var nfcManager = NFCManager()
    @State private var errorMessage: String?
    @State private var isSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text(isSuccess ? "Scan Successful!" : "Scan NFC Tag")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appForeground)
                .padding(.top, 12)

            ZStack {
                Circle()
                    .stroke(isSuccess ? Color.green.opacity(0.15) : Color.appAccent.opacity(0.15), lineWidth: 3)
                    .frame(width: 100, height: 100)
                
                if nfcManager.isScanning {
                    Circle()
                        .stroke(Color.appAccent.opacity(0.3), lineWidth: 3)
                        .frame(width: 100, height: 100)
                        .scaleEffect(1.3)
                        .opacity(0)
                        .animation(.easeOut(duration: 1.2).repeatForever(autoreverses: false), value: nfcManager.isScanning)
                }
                
                Image(systemName: isSuccess ? "checkmark" : "wave.3.right")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(isSuccess ? .green : .appAccent)
            }
            .padding(.vertical, 10)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(height: 40)
            } else {
                Text(isSuccess ? "Identity verified. Toggling protection..." : "Hold your phone near the NFC tag")
                    .font(.system(size: 14))
                    .foregroundColor(.appMutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .frame(height: 40)
            }

            Button {
                nfcManager.startScanning()
                errorMessage = nil
            } label: {
                Text(errorMessage != nil ? "Try Again" : "Start Scan")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .disabled(isSuccess)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            // Automatically start scanning if a tag is paired
            if UserSettings.shared.pairedNFCID != nil {
                nfcManager.startScanning()
            } else {
                errorMessage = "No tag paired. Please go to Settings to set up your NFC tag."
            }
        }
        .onReceive(nfcManager.$scannedTagID) { tagID in
            guard let tagID = tagID else { return }
            
            if tagID == UserSettings.shared.pairedNFCID {
                Haptics.notification(.success)
                isSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    onSuccess()
                    isPresented = false
                }
            } else {
                Haptics.notification(.error)
                errorMessage = "This tag is not paired with your account. Access denied."
                nfcManager.stopScanning()
            }
        }
        .onReceive(nfcManager.$error) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}
