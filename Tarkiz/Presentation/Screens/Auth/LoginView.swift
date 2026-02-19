import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            Text("Welcome Back")
                .font(Typography.heading)
                .foregroundColor(AppTheme.primaryColor)
            
            VStack(spacing: AppTheme.Spacing.medium) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(AppTheme.errorColor)
                    .font(Typography.caption)
            }
            
            CustomButton(title: "Log In", isLoading: viewModel.isLoading) {
                viewModel.login()
            }
            .padding(.horizontal)
            
            Button("Login with Face ID") {
                viewModel.loginWithBiometrics()
            }
            .foregroundColor(AppTheme.primaryColor)
            .padding(.top, AppTheme.Spacing.small)
            
            Spacer()
        }
        .padding(.top, 50)
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}

#Preview {
    LoginView()
}
