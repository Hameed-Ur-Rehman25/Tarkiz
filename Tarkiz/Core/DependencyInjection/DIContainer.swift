import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    // Services
    lazy var networkService: NetworkService = NetworkServiceImpl()
    
    lazy var keychainService: KeychainService = KeychainServiceImpl()
    
    // Repositories (Placeholders for now)
    // func makeUserRepository() -> UserRepository {
    //     UserRepositoryImpl(
    //         networkService: networkService,
    //         keychainService: keychainService
    //     )
    // }
    
    private init() {}
}
