import SwiftUI

struct AppItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let usage: String
}

import FamilyControls

struct BlockAppsView: View {
    @ObservedObject var viewModel: SetupViewModel
    @StateObject private var screenTimeService = ScreenTimeService.shared
    @State private var isPickerPresented = false
    
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
            
            Text("Block the apps\nthat you select")
                .font(Typography.title)
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.primaryColor)
            
            Text("\(screenTimeService.selection.applications.count + screenTimeService.selection.categories.count) distractions selected")
                .font(Typography.heading)
                .foregroundColor(AppTheme.primaryColor)
                .padding(.vertical, 10)
            
            // App Selection Button
            Button(action: {
                isPickerPresented = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "apps.iphone.badge.plus")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.sageGreen)
                    
                    Text("Select Apps to Block")
                        .font(Typography.body.weight(.semibold))
                        .foregroundColor(AppTheme.primaryColor)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.sageGreen.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTimeService.selection)
            
            Spacer()
            
            Text("Tip: You can change these later in settings")
                .font(Typography.caption)
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            // Complete Setup Button
            Button(action: {
                screenTimeService.applyShield()
                withAnimation {
                     viewModel.nextStep()
                }
            }) {
                Text("Complete setup")
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.sageGreen)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.requestScreenTimeAuthorization()
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}
