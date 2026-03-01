import Foundation

// MARK: - AlAdhan Calculation Methods

struct CalculationMethod: Identifiable, Hashable {
    let id: Int           // AlAdhan method ID
    let name: String
    let description: String
    let region: String
}

let allCalculationMethods: [CalculationMethod] = [
    .init(id: 1,  name: "University of Karachi",        description: "Fajr: 18°, Isha: 18°",      region: "Pakistan, South Asia"),
    .init(id: 2,  name: "ISNA",                         description: "Fajr: 15°, Isha: 15°",      region: "North America"),
    .init(id: 3,  name: "Muslim World League",           description: "Fajr: 18°, Isha: 17°",      region: "Europe, Far East"),
    .init(id: 4,  name: "Umm al-Qura",                  description: "Fajr: 18.5°, Isha: 90 min", region: "Arabian Peninsula"),
    .init(id: 5,  name: "Egyptian General Authority",    description: "Fajr: 19.5°, Isha: 17.5°",  region: "Africa, Middle East"),
    .init(id: 7,  name: "Institute of Geophysics, Tehran", description: "Fajr: 17.7°, Isha: 14°", region: "Iran"),
    .init(id: 8,  name: "Gulf Region",                  description: "Fajr: 19.5°, Isha: 90 min", region: "Gulf Countries"),
    .init(id: 9,  name: "Kuwait",                       description: "Fajr: 18°, Isha: 17.5°",    region: "Kuwait"),
    .init(id: 10, name: "Qatar",                        description: "Fajr: 18°, Isha: 90 min",   region: "Qatar"),
    .init(id: 11, name: "Majlis Ugama Islam Singapura", description: "Fajr: 20°, Isha: 18°",      region: "Singapore"),
    .init(id: 12, name: "Union Organization Islamic de France", description: "Fajr: 12°, Isha: 12°", region: "France"),
    .init(id: 13, name: "Diyanet İşleri Başkanlığı",   description: "Fajr: 18°, Isha: 17°",      region: "Turkey"),
    .init(id: 15, name: "Spiritual Administration of Muslims of Russia", description: "Fajr: 16°, Isha: 15°", region: "Russia"),
]

// MARK: - API Endpoint

struct PrayerTimesEndpoint: APIEndpoint {

    let latitude: Double
    let longitude: Double
    let methodId: Int

    private static let base = "https://api.aladhan.com/v1/timings"

    var url: URL {
        var components = URLComponents(string: Self.base)!
        components.queryItems = [
            .init(name: "latitude",  value: "\(latitude)"),
            .init(name: "longitude", value: "\(longitude)"),
            .init(name: "method",    value: "\(methodId)"),
        ]
        return components.url!
    }

    func urlRequest() throws -> URLRequest {
        URLRequest(url: url)
    }
}
