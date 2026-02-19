import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    // Services
    lazy var networkService: NetworkService = NetworkServiceImpl()
    lazy var keychainService: KeychainService = KeychainServiceImpl()
    lazy var biometricAuthService: BiometricAuthService = BiometricAuthServiceImpl()
    lazy var authService: AuthService = AuthServiceImpl(networkService: networkService, keychainService: keychainService, biometricService: biometricAuthService)
    
    // Repositories (Placeholders for now)
    // func makeUserRepository() -> UserRepository {
    //     UserRepositoryImpl(
    //         networkService: networkService,
    //         keychainService: keychainService
    //     )
    // }
    
    private init() {}
}
