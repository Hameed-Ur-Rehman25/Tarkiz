import SwiftUI

struct CalculationMethodView: View {
    @ObservedObject var viewModel: SetupViewModel
    @State private var selectedMethod: String?
    
    let methods = [
        ("Muslim World League", "Fajr: 18°, Isha: 17°", "Europe, Far East"),
        ("ISNA", "Fajr: 15°, Isha: 15°", "North America"),
        ("Egyptian General Authority", "Fajr: 19.5°, Isha: 17.5°", "Africa, Middle East"),
        ("Umm al-Qura", "Fajr: 18.5°, Isha: 90min", "Arabian Peninsula"),
        ("University of Karachi", "Fajr: 18°, Isha: 18°", "Pakistan, South Asia")
    ]
    
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
            
            Text("Choose calculation\nmethod")
                .font(Typography.title)
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.primaryColor)
            
            Text("Based on your region or school of thought")
                .font(Typography.body)
                .foregroundColor(.gray)
            
            // Methods List
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(methods, id: \.0) { method in
                        Button(action: {
                            selectedMethod = method.0
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(method.0)
                                        .font(Typography.body.weight(.semibold))
                                        .foregroundColor(AppTheme.primaryColor)
                                    
                                    HStack {
                                        Text(method.1)
                                            .font(Typography.caption)
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(6)
                                        
                                        Text(method.2)
                                            .font(Typography.caption)
                                            .foregroundColor(AppTheme.sageGreen)
                                    }
                                }
                                Spacer()
                                
                                Circle()
                                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 1)
                                    .background(Circle().fill(selectedMethod == method.0 ? AppTheme.sageGreen : Color.clear))
                                    .frame(width: 24, height: 24)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedMethod == method.0 ? AppTheme.sageGreen : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            
            // Continue Button
            Button(action: {
                // Save method to ViewModel/Context
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
            .opacity(selectedMethod != nil ? 1.0 : 0.5)
            .disabled(selectedMethod == nil)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}
