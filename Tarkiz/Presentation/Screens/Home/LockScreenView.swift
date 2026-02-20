import SwiftUI

// MARK: - LockScreenView

struct LockScreenView: View {
    var onUnlockTapped: () -> Void = {}

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.appAccent.opacity(0.9), Color.appAccent],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Decorative blurs
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 128, height: 128)
                .blur(radius: 40)
                .offset(x: -80, y: -200)
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: 80, y: 160)

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Lock icon
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 96, height: 96)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .pulseAnimation()
                .padding(.bottom, 32)

                // Message
                Text("It's prayer time")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.bottom, 16)

                Text("Distractions are paused.\nTake this moment to connect.")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.bottom, 48)

                // Prayer emoji
                Text("🤲")
                    .font(.system(size: 60))
                    .opacity(0.6)
                    .padding(.bottom, 48)

                // Unlock button
                Button(action: onUnlockTapped) {
                    HStack(spacing: 10) {
                        Image(systemName: "wave.3.right")
                            .font(.system(size: 16))
                        Text("Unlock with NFC")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.appAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
                }
                .padding(.horizontal, 32)

                Text("Scan your NFC tag to unlock")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 24)

                Spacer()
            }
            .padding(.horizontal, 32)
        }
    }
}
