import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                Text("Create Account")
                    .font(Typography.heading)
                    .foregroundColor(AppTheme.primaryColor)
                
                VStack(spacing: AppTheme.Spacing.medium) {
                    TextField("Full Name", text: $viewModel.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(AppTheme.errorColor)
                        .font(Typography.caption)
                }
                
                CustomButton(title: "Sign Up", isLoading: viewModel.isLoading) {
                    viewModel.register()
                }
                .padding(.horizontal)
                
                Button("Already have an account? Log In") {
                    presentationMode.wrappedValue.dismiss()
                }
                .font(Typography.caption)
                .foregroundColor(AppTheme.secondaryColor)
            }
            .padding(.top, 50)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    RegisterView()
}
