import Foundation
import Combine

/// Persists user preferences to UserDefaults.
/// All prayer times screens read/write through this single source of truth.
final class UserSettings: ObservableObject {

    static let shared = UserSettings()

    // MARK: - Location

    @Published var locationCity: String {
        didSet { UserDefaults.standard.set(locationCity, forKey: Keys.locationCity) }
    }
    @Published var locationCountry: String {
        didSet { UserDefaults.standard.set(locationCountry, forKey: Keys.locationCountry) }
    }
    @Published var latitude: Double {
        didSet { UserDefaults.standard.set(latitude, forKey: Keys.latitude) }
    }
    @Published var longitude: Double {
        didSet { UserDefaults.standard.set(longitude, forKey: Keys.longitude) }
    }

    // MARK: - Calculation Method

    @Published var calculationMethodId: Int {
        didSet { UserDefaults.standard.set(calculationMethodId, forKey: Keys.calculationMethodId) }
    }
    @Published var calculationMethodName: String {
        didSet { UserDefaults.standard.set(calculationMethodName, forKey: Keys.calculationMethodName) }
    }

    // MARK: - Asr Standard (0 = Shafi'i / Standard, 1 = Hanafi)

    @Published var asrJuristic: Int {
        didSet { UserDefaults.standard.set(asrJuristic, forKey: Keys.asrJuristic) }
    }

    // MARK: - Time Adjustments (minutes)

    @Published var fajrAdjust: Int {
        didSet { UserDefaults.standard.set(fajrAdjust, forKey: Keys.fajrAdjust) }
    }
    @Published var dhuhrAdjust: Int {
        didSet { UserDefaults.standard.set(dhuhrAdjust, forKey: Keys.dhuhrAdjust) }
    }
    @Published var asrAdjust: Int {
        didSet { UserDefaults.standard.set(asrAdjust, forKey: Keys.asrAdjust) }
    }
    @Published var maghribAdjust: Int {
        didSet { UserDefaults.standard.set(maghribAdjust, forKey: Keys.maghribAdjust) }
    }
    @Published var ishaAdjust: Int {
        didSet { UserDefaults.standard.set(ishaAdjust, forKey: Keys.ishaAdjust) }
    }

    // MARK: - Onboarding

    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Init

    private init() {
        let d = UserDefaults.standard
        locationCity           = d.string(forKey: Keys.locationCity)    ?? ""
        locationCountry        = d.string(forKey: Keys.locationCountry) ?? ""
        latitude               = d.double(forKey: Keys.latitude)
        longitude              = d.double(forKey: Keys.longitude)
        calculationMethodId    = d.object(forKey: Keys.calculationMethodId) != nil
                                    ? d.integer(forKey: Keys.calculationMethodId) : 3   // Default: MWL
        calculationMethodName  = d.string(forKey: Keys.calculationMethodName) ?? "Muslim World League"
        asrJuristic            = d.integer(forKey: Keys.asrJuristic)    // 0 = Shafi'i
        fajrAdjust             = d.integer(forKey: Keys.fajrAdjust)
        dhuhrAdjust            = d.integer(forKey: Keys.dhuhrAdjust)
        asrAdjust              = d.integer(forKey: Keys.asrAdjust)
        maghribAdjust          = d.integer(forKey: Keys.maghribAdjust)
        ishaAdjust             = d.integer(forKey: Keys.ishaAdjust)
        hasCompletedOnboarding = d.bool(forKey: Keys.hasCompletedOnboarding)
    }

    // MARK: - Helpers

    /// Returns true if coordinates have been set (non-zero location).
    var hasLocation: Bool { latitude != 0 || longitude != 0 }

    // MARK: - Keys

    private enum Keys {
        static let locationCity           = "locationCity"
        static let locationCountry        = "locationCountry"
        static let latitude               = "latitude"
        static let longitude              = "longitude"
        static let calculationMethodId    = "calculationMethodId"
        static let calculationMethodName  = "calculationMethodName"
        static let asrJuristic            = "asrJuristic"
        static let fajrAdjust             = "fajrAdjust"
        static let dhuhrAdjust            = "dhuhrAdjust"
        static let asrAdjust              = "asrAdjust"
        static let maghribAdjust          = "maghribAdjust"
        static let ishaAdjust             = "ishaAdjust"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
}
