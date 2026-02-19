import SwiftUI
import CoreLocation

struct LocationSetupView: View {
    @ObservedObject var viewModel: SetupViewModel
    
    let cities = ["New York", "London", "Dubai", "Makkah", "Cairo", "Istanbul", "Karachi", "Toronto"]
    let flags = ["🇺🇸", "🇬🇧", "🇦🇪", "🇸🇦", "🇪🇬", "🇹🇷", "🇵🇰", "🇨🇦"]
    
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
            
            Text("Set your location\nfor prayer times")
                .font(Typography.title)
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.primaryColor)
            
            // Use My Location Section
            Button(action: {
                viewModel.requestLocation()
            }) {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(AppTheme.sageGreen)
                    
                    VStack(alignment: .leading) {
                        Text("Use My Location")
                            .font(Typography.body.weight(.semibold))
                            .foregroundColor(AppTheme.sageGreen)
                        Text("Auto-detect via GPS")
                            .font(Typography.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding()
                .background(AppTheme.sageGreen.opacity(0.1))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.sageGreen.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            
            HStack {
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2))
                Text("or select a city").font(Typography.caption).foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2))
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            // City Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(0..<cities.count, id: \.self) { index in
                        Button(action: {
                            viewModel.selectedLocation = cities[index]
                        }) {
                            HStack {
                                Text(flags[index])
                                VStack(alignment: .leading) {
                                    Text(cities[index])
                                        .font(Typography.body)
                                        .foregroundColor(AppTheme.primaryColor)
                                    // Placeholder country name
                                    Text("Country")
                                        .font(Typography.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Continue Button
            Button(action: {
                withAnimation {
                     viewModel.nextStep()
                }
            }) {
                Text("Continue")
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.sageGreen)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
            .opacity(viewModel.selectedLocation != nil ? 1.0 : 0.5)
            .disabled(viewModel.selectedLocation == nil)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}
