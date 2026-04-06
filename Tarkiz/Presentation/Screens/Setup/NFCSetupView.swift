import SwiftUI
import Combine

struct NFCSetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    @StateObject private var nfcManager = NFCManager()
    @State private var cancellables = Set<AnyCancellable>()
    @State private var isScanning = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    withAnimation {
                        viewModel.previousStep()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Tap your tag\nwhenever you\nneed to focus")
                .font(Typography.heading.weight(.bold))
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.primaryColor)
                .padding(.top, 20)
            
            Spacer()
            
            // NFC Icon Animation
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .stroke(isScanning ? AppTheme.sageGreen.opacity(0.5) : Color.clear, lineWidth: 2)
                    .frame(width: 160, height: 160)
                    .scaleEffect(isScanning ? 1.2 : 0.8)
                    .opacity(isScanning ? 0 : 1)
                    .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: isScanning)
                
                Image(systemName: "wave.3.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(AppTheme.sageGreen)
            }
            .padding(.vertical, 40)
            
            Text("Ready to scan")
                .font(Typography.heading)
                .foregroundColor(AppTheme.primaryColor)
            
            Spacer()
            
            // Scan Button
            Button(action: {
                nfcManager.startScanning()
            }) {
                Text(nfcManager.isScanning ? "Scanning..." : "Scan NFC Tag")
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.sageGreen)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(nfcManager.isScanning)
            .onAppear {
                nfcManager.$scannedTagID
                    .compactMap { $0 }
                    .sink { _ in
                        viewModel.completeSetup()
                    }
                    .store(in: &cancellables)
            }
            
            Button("Skip for now") {
                viewModel.skip()
            }
            .font(Typography.caption)
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}
