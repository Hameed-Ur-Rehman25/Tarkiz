import SwiftUI

struct WelcomeView: View {
    @ObservedObject var viewModel: SetupViewModel
    
    var body: some View {
        ZStack {
            // Background
            AppTheme.beigeBackground.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Title
                Text("Protect your prayer\ntime from distractions")
                    .font(Typography.title)
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.primaryColor)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                
                // Mosque Card Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(AppTheme.surfaceColor)
                        .frame(width: 180, height: 180)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Simple Mosque Icon (SF Symbols composition as placeholder)
                    VStack(spacing: 0) {
                        Image(systemName: "building.columns.fill") // Dome-ish
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.orange.opacity(0.8))
                    }
                    
                    // Decorative corners
                    VStack {
                        HStack {
                            CornerView(rotation: 0)
                            Spacer()
                            CornerView(rotation: 90)
                        }
                        Spacer()
                        HStack {
                            CornerView(rotation: -90)
                            Spacer()
                            CornerView(rotation: 180)
                        }
                    }
                    .frame(width: 220, height: 220)
                    .opacity(0.3)
                }
                .padding(.bottom, 60)
                
                Spacer()
                
                // Bottom Sheet Container
                VStack(spacing: 20) {
                    Text("Ready to focus?")
                        .font(Typography.heading)
                        .foregroundColor(AppTheme.primaryColor)
                        .padding(.top, 30)
                    
                    Button(action: {
                        withAnimation {
                            viewModel.nextStep()
                        }
                    }) {
                        Text("Get Started")
                            .font(Typography.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.sageGreen)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 24)
                    
                    Button("Skip Setup") {
                        viewModel.skip()
                    }
                    .font(Typography.body)
                    .foregroundColor(.gray)
                    .padding(.bottom, 30)
                }
                .background(AppTheme.surfaceColor)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

// Helper for corner decorations
struct CornerView: View {
    let rotation: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .stroke(Color.gray, lineWidth: 2)
            .frame(width: 40, height: 40)
            .mask(
                VStack {
                    HStack {
                        Rectangle().frame(width: 20, height: 20)
                        Spacer()
                    }
                    Spacer()
                }
            )
            .rotationEffect(.degrees(rotation))
    }
}

// Helper for partial corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
