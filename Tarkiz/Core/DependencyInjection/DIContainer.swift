import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    // Services
    lazy var networkService: NetworkService = NetworkServiceImpl()
    
    lazy var keychainService: KeychainService = KeychainServiceImpl()
    
    // Repositories
    lazy var prayerTimesRepository: PrayerTimesRepository = PrayerTimesRepositoryImpl(
        networkService: networkService
    )
    
    private init() {}
}
