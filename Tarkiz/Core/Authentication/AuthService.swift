import Foundation
import Combine

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String?
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

protocol AuthService {
    func login(email: String, password: String) async throws -> AuthResponse
    func loginWithBiometrics() async throws -> AuthResponse
    func register(name: String, email: String, password: String) async throws -> AuthResponse
    func logout()
    var currentUser: User? { get }
}

class AuthServiceImpl: AuthService {
    private let networkService: NetworkService
    private let keychainService: KeychainService
    private let biometricService: BiometricAuthService
    
    var currentUser: User?
    
    init(networkService: NetworkService = DIContainer.shared.networkService,
         keychainService: KeychainService = DIContainer.shared.keychainService,
         biometricService: BiometricAuthService = DIContainer.shared.biometricAuthService) {
        self.networkService = networkService
        self.keychainService = keychainService
        self.biometricService = biometricService
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        // Placeholder implementation
        // real implementation would use networkService.request(...)
        
        let user = User(id: UUID().uuidString, email: email, name: "User")
        let response = AuthResponse(user: user, accessToken: "mock_access_token", refreshToken: "mock_refresh_token")
        
        saveTokens(response)
        currentUser = user
        return response
    }
    
    func loginWithBiometrics() async throws -> AuthResponse {
        let success = try await biometricService.authenticate()
        guard success else { throw BiometricError.failed }
        
        // In a real app, you might retrieve the token from Keychain here and validate it
        // Or if using specific biometric-protected keychain items
        
        // For now, return a mock response
        let user = User(id: UUID().uuidString, email: "biometric@user.com", name: "Biometric User")
        let response = AuthResponse(user: user, accessToken: "mock_biometric_token", refreshToken: "mock_biometric_refresh_token")
        
        currentUser = user
        return response
    }
    
    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        // Placeholder implementation
        let user = User(id: UUID().uuidString, email: email, name: name)
        let response = AuthResponse(user: user, accessToken: "mock_access_token", refreshToken: "mock_refresh_token")
        
        saveTokens(response)
        currentUser = user
        return response
    }
    
    func logout() {
        try? keychainService.delete(key: .accessToken)
        try? keychainService.delete(key: .refreshToken)
        currentUser = nil
    }
    
    private func saveTokens(_ response: AuthResponse) {
        try? keychainService.save(response.accessToken, key: .accessToken)
        try? keychainService.save(response.refreshToken, key: .refreshToken)
    }
}
