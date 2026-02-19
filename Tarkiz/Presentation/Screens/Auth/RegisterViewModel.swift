import SwiftUI
import Combine

class RegisterViewModel: ObservableObject {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegistered = false
    
    private let authService: AuthService
    
    init(authService: AuthService = DIContainer.shared.authService) {
        self.authService = authService
    }
    
    func register() {
        guard validateInput() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await authService.register(name: name, email: email, password: password)
                await MainActor.run {
                    self.isLoading = false
                    self.isRegistered = true
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
        if name.isEmpty {
            errorMessage = "Please enter your name."
            return false
        }
        if email.isEmpty {
            errorMessage = "Please enter your email."
            return false
        }
        if password.isEmpty {
            errorMessage = "Please enter a password."
            return false
        }
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return false
        }
        return true
    }
}
