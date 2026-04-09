import SwiftUI

struct CalculationMethodSettingsView: View {
    @ObservedObject var viewModel: PrayerSettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack {
                            Button { presentationMode.wrappedValue.dismiss() } label: {
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
                        }
                        .overlay(
                            Text("Calculation Method")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appForeground)
                        )
                        .padding(.top, 24)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                        
                        // Methods List
                        VStack(spacing: 12) {
                            ForEach(viewModel.methods) { method in
                                Button {
                                    viewModel.selectedMethodId = method.id
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(method.name)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(viewModel.selectedMethodId == method.id ? .appPrimary : .appForeground)
                                            Text(method.region)
                                                .font(.system(size: 13))
                                                .foregroundColor(.appMutedForeground)
                                        }
                                        Spacer()
                                        if viewModel.selectedMethodId == method.id {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.appPrimary)
                                        }
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(viewModel.selectedMethodId == method.id ? Color.appPrimary.opacity(0.1) : Color.appSecondary.opacity(0.5))
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
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
