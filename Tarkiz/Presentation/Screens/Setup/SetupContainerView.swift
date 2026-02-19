import SwiftUI

struct SetupContainerView: View {
    @StateObject private var viewModel = SetupViewModel()
    @Environment(\.managedObjectContext) var viewContext // To pass down if needed
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        ZStack {
            AppTheme.backgroundColor.ignoresSafeArea()
            
            switch viewModel.currentStep {
            case .welcome:
                WelcomeView(viewModel: viewModel)
            case .location:
                LocationSetupView(viewModel: viewModel)
            case .calculation:
                CalculationMethodView(viewModel: viewModel)
            case .blockApps:
                BlockAppsView(viewModel: viewModel)
            case .nfc:
                NFCSetupView(viewModel: viewModel)
            }
        }
        .animation(.easeInOut, value: viewModel.currentStep)
    }
}
