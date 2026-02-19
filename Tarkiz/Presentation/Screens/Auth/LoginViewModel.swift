import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false
    
    private let authService: AuthService
    
    init(authService: AuthService = DIContainer.shared.authService) {
        self.authService = authService
    }
    
    func login() {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authService.login(email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                    self.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginWithBiometrics() {
        isLoading = true
        errorMessage = nil
         Task {
            do {
                _ = try await authService.loginWithBiometrics()
                await MainActor.run {
                    self.isLoading = false
                    self.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func validateInput() -> Bool {
        if email.isEmpty {
            errorMessage = "Please enter your email."
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter your password."
            return false
        }
        return true
    }
}
