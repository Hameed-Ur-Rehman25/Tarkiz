import Foundation

// MARK: - Response Models

struct PrayerTimesResponse: Decodable {
    let code: Int
    let status: String
    let data: PrayerData
}

struct PrayerData: Decodable {
    let timings: PrayerTimings
    let date: PrayerDate
    let meta: PrayerMeta
}

struct PrayerTimings: Decodable {
    let Fajr: String
    let Sunrise: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct PrayerDate: Decodable {
    let readable: String          // e.g. "01 Mar 2026"
    let hijri: HijriDate
}

struct HijriDate: Decodable {
    let date: String              // e.g. "12-09-1447"
    let month: HijriMonth
    let year: String
}

struct HijriMonth: Decodable {
    let en: String                // e.g. "Ramaḍān"
    let ar: String
}

struct PrayerMeta: Decodable {
    let timezone: String          // e.g. "Asia/Karachi"
    let method: MethodInfo
}

struct MethodInfo: Decodable {
    let id: Int
    let name: String
}
