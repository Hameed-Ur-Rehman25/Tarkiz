import SwiftUI
import Combine

// MARK: - NFCPairingViewModel

class NFCPairingViewModel: ObservableObject {
    @Published var scanState: NFCScanState = .idle

    func startScan() {
        Haptics.impact(.medium)
        scanState = .scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            Haptics.notification(.success)
            self?.scanState = .success
        }
    }

    func reset() {
        scanState = .idle
    }
}

// MARK: - NFCPairingView

struct NFCPairingView: View {
    @StateObject private var viewModel = NFCPairingViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

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
                    Text("NFC Tag Setup")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.appForeground)
                    Spacer().frame(width: 40)
                }
                .padding(.top, 56)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

                switch viewModel.scanState {
                case .idle:    NFCInstructionsView { viewModel.startScan() }
                case .scanning: NFCScanningView { viewModel.reset() }
                case .success:  NFCSuccessView(coordinator: coordinator)
                }

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Instructions View

struct NFCInstructionsView: View {
    var onScan: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // NFC Tag Illustration
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.appCard)
                    .shadow(color: .black.opacity(0.12), radius: 25, y: 10)
                    .frame(width: 160, height: 160)

                CornerBrackets(size: 180, inset: 0, bracketLength: 24, cornerRadius: 8)
                    .stroke(Color.appMutedForeground.opacity(0.3), lineWidth: 2)
                    .frame(width: 180, height: 180)

                VStack(spacing: 4) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 36))
                        .foregroundColor(.appPrimary)
                    Text("NFC")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.appMutedForeground)
                }
            }
            .padding(.top, 16)

            // Steps
            VStack(alignment: .leading, spacing: 16) {
                NFCInstructionStep(number: "1", text: "Have an NFC tag ready")
                NFCInstructionStep(number: "2", text: "Tap 'Scan Tag' below")
                NFCInstructionStep(number: "3", text: "Hold your iPhone near the tag")
            }
            .padding(.horizontal, 40)

            Button(action: onScan) {
                HStack(spacing: 10) {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 16))
                    Text("Scan NFC Tag")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.appPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 24)
        }
    }
}

struct NFCInstructionStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appSecondary)
                    .frame(width: 32, height: 32)
                Text(number)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appMutedForeground)
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.appForeground)
        }
    }
}

// MARK: - Scanning View

struct NFCScanningView: View {
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.appPrimary.opacity(0.15 + Double(i) * 0.05), lineWidth: 2)
                        .frame(width: CGFloat(100 + i * 40), height: CGFloat(100 + i * 40))
                        .pulseAnimation()
                }
                Circle()
                    .fill(Color.appPrimary)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 220)

            Text("Hold iPhone near NFC tag")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appForeground)

            Text("Continue to hold until you feel a vibration")
                .font(.system(size: 14))
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)

            Button(action: onCancel) {
                Text("Cancel")
                    .font(.system(size: 16))
                    .foregroundColor(.appMutedForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appSecondary.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Success View

struct NFCSuccessView: View {
    let coordinator: AppCoordinator

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 130, height: 130)
                Circle()
                    .fill(Color.green)
                    .frame(width: 90, height: 90)
                    .shadow(color: .green.opacity(0.4), radius: 20, y: 10)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, 8)

            Text("Tag Paired Successfully!")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appForeground)

            Text("Your NFC tag is now linked to Tarkiz.\nScan it to start prayer mode.")
                .font(.system(size: 16))
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button { coordinator.pop() } label: {
                Text("Done")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 24)
        }
    }
}
