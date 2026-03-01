import Foundation
import Combine

// MARK: - Repository Protocol

protocol PrayerTimesRepository {
    func fetchTodayTimings(lat: Double, lon: Double, methodId: Int) async throws -> PrayerTimesResponse
    func invalidateCache()
}

// MARK: - Implementation

final class PrayerTimesRepositoryImpl: PrayerTimesRepository {

    private let networkService: NetworkService

    // Simple in-memory cache: cache key is "lat,lon,methodId,date"
    private var cache: [String: PrayerTimesResponse] = [:]

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func fetchTodayTimings(lat: Double, lon: Double, methodId: Int) async throws -> PrayerTimesResponse {
        let dateKey = todayDateString()
        let cacheKey = "\(lat),\(lon),\(methodId),\(dateKey)"

        if let cached = cache[cacheKey] {
            return cached
        }

        let endpoint = PrayerTimesEndpoint(latitude: lat, longitude: lon, methodId: methodId)
        let response: PrayerTimesResponse = try await networkService.request(endpoint, method: .get, body: nil as String?)
        cache[cacheKey] = response
        return response
    }

    // MARK: - Helpers

    func invalidateCache() {
        cache.removeAll()
    }

    private func todayDateString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
}
