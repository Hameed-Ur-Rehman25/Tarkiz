import SwiftUI
import Combine
import CoreLocation

// MARK: - Data Model

struct Prayer: Identifiable {
    let id = UUID()
    let name: String
    let arabicName: String
    let time: String          // Display string e.g. "05:15"
    let icon: String
    var isActive: Bool = false
    var isPassed: Bool = false
}

// Placeholder prayers shown before real data loads
private let placeholderPrayers: [Prayer] = [
    Prayer(name: "Fajr",    arabicName: "الفجر",  time: "--:--", icon: "moon.fill"),
    Prayer(name: "Sunrise", arabicName: "الشروق", time: "--:--", icon: "sunrise.fill"),
    Prayer(name: "Dhuhr",   arabicName: "الظهر",  time: "--:--", icon: "sun.max.fill"),
    Prayer(name: "Asr",     arabicName: "العصر",  time: "--:--", icon: "cloud.sun.fill"),
    Prayer(name: "Maghrib", arabicName: "المغرب", time: "--:--", icon: "sunset.fill"),
    Prayer(name: "Isha",    arabicName: "العشاء", time: "--:--", icon: "sparkles"),
]

// MARK: - PrayerTimesViewModel

@MainActor
class PrayerTimesViewModel: ObservableObject {

    @Published var prayers: [Prayer] = placeholderPrayers
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var hijriDate: String = ""
    @Published var locationDisplay: String = ""
    @Published var methodDisplay: String = ""

    private let repository: PrayerTimesRepository
    private let settings: UserSettings

    init(
        repository: PrayerTimesRepository = DIContainer.shared.prayerTimesRepository,
        settings: UserSettings = .shared
    ) {
        self.repository = repository
        self.settings   = settings
    }

    var activePrayer: Prayer? { prayers.first { $0.isActive } }
    var nextPrayer:   Prayer? { prayers.first { !$0.isPassed && !$0.isActive } }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date()).uppercased()
    }

    // MARK: - Fetch

    func loadPrayerTimes() async {
        guard settings.hasLocation else {
            // No location set yet — show empty state
            errorMessage = "Location not set. Please complete setup in Settings."
            return
        }

        isLoading    = true
        errorMessage = nil

        do {
            let response = try await repository.fetchTodayTimings(
                lat:      settings.latitude,
                lon:      settings.longitude,
                methodId: settings.calculationMethodId
            )
            applyResponse(response)
        } catch {
            errorMessage = "Could not load prayer times.\n\(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Apply Response

    private func applyResponse(_ response: PrayerTimesResponse) {
        let t       = response.data.timings
        let hijri   = response.data.date.hijri
        let tz      = response.data.meta.timezone

        hijriDate       = "\(hijri.date.components(separatedBy: "-").first ?? "") \(hijri.month.en) \(hijri.year)"
        locationDisplay = settings.locationCity.isEmpty
                            ? "" : "\(settings.locationCity), \(settings.locationCountry)"
        methodDisplay   = settings.calculationMethodName

        // Build raw list with adjustments applied
        let raw: [(name: String, arabicName: String, rawTime: String, icon: String)] = [
            ("Fajr",    "الفجر",  t.Fajr,    "moon.fill"),
            ("Sunrise", "الشروق", t.Sunrise, "sunrise.fill"),
            ("Dhuhr",   "الظهر",  t.Dhuhr,   "sun.max.fill"),
            ("Asr",     "العصر",  t.Asr,     "cloud.sun.fill"),
            ("Maghrib", "المغرب", t.Maghrib,  "sunset.fill"),
            ("Isha",    "العشاء", t.Isha,     "sparkles"),
        ]

        let adjustments = [
            settings.fajrAdjust, 0,
            settings.dhuhrAdjust, settings.asrAdjust,
            settings.maghribAdjust, settings.ishaAdjust,
        ]

        let now = Date()

        prayers = raw.enumerated().map { idx, entry in
            let displayTime = applyAdjustment(
                rawTime: entry.rawTime,
                minutes: adjustments[idx],
                timezone: tz
            )
            let prayerDate = prayerDate(from: entry.rawTime, timezone: tz)

            return Prayer(
                name:       entry.name,
                arabicName: entry.arabicName,
                time:       displayTime,
                icon:       entry.icon,
                isActive:   false,
                isPassed:   prayerDate != nil && prayerDate! < now
            )
        }

        // Mark the current active prayer (last passed one that isn't Sunrise)
        markActivePrayer()
    }

    private func markActivePrayer() {
        // Find the last prayer whose time has passed (excluding Sunrise as an "active" slot)
        var lastPassedIdx: Int? = nil
        for (idx, prayer) in prayers.enumerated() {
            if prayer.isPassed && prayer.name != "Sunrise" {
                lastPassedIdx = idx
            }
        }

        // The active prayer is the one whose time has passed but the next one hasn't yet
        if let passedIdx = lastPassedIdx {
            let nextIdx = passedIdx + 1
            if nextIdx < prayers.count {
                // If next prayer hasn't passed either, lastPassed is active
                prayers[passedIdx].isActive = true
                prayers[passedIdx].isPassed = false
            }
        } else {
            // Before Fajr — Isha from yesterday would be active, show nothing active
        }
    }

    // MARK: - Time Helpers

    private func applyAdjustment(rawTime: String, minutes: Int, timezone: String) -> String {
        guard let date = prayerDate(from: rawTime, timezone: timezone) else { return rawTime }
        let adjusted = date.addingTimeInterval(TimeInterval(minutes * 60))

        let f = DateFormatter()
        f.dateFormat  = "hh:mm a"
        f.amSymbol    = "AM"
        f.pmSymbol    = "PM"
        f.timeZone    = TimeZone(identifier: timezone) ?? .current
        return f.string(from: adjusted)
    }

    private func prayerDate(from rawTime: String, timezone: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.timeZone   = TimeZone(identifier: timezone) ?? .current

        // Combine today's date with the API time string
        let cal  = Calendar.current
        let today = cal.dateComponents(in: TimeZone(identifier: timezone) ?? .current, from: Date())
        var comps = DateComponents()
        comps.year   = today.year
        comps.month  = today.month
        comps.day    = today.day
        comps.timeZone = TimeZone(identifier: timezone) ?? .current

        let parts = rawTime.components(separatedBy: ":")
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let min  = Int(parts[1].prefix(2)) else { return nil }
        comps.hour   = hour
        comps.minute = min
        comps.second = 0
        return cal.date(from: comps)
    }

    // MARK: - Invalidate on Settings Change

    func refreshIfNeeded() async {
        repository.invalidateCache()
        await loadPrayerTimes()
    }
}

// MARK: - PrayerTimesView

struct PrayerTimesView: View {
    @StateObject private var viewModel = PrayerTimesViewModel()

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 12) {
                        // Header
                        VStack(spacing: 4) {
                            Text(viewModel.formattedDate)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.appMutedForeground)
                                .tracking(0.5)
                            Text("Prayer Times")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.appForeground)
                            if !viewModel.hijriDate.isEmpty {
                                Text(viewModel.hijriDate)
                                    .font(.system(size: 12))
                                    .foregroundColor(.appMutedForeground)
                            }
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 8)

                        // Error banner (small, non-blocking)
                        if let error = viewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                Text(error)
                                    .font(.system(size: 12))
                                    .foregroundColor(.appMutedForeground)
                                Spacer()
                                Button {
                                    Task { await viewModel.loadPrayerTimes() }
                                } label: {
                                    Text("Retry")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(.appPrimary)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.orange.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal, 16)
                        }

                        // Current Prayer Card — always visible
                        if let active = viewModel.activePrayer {
                            CurrentPrayerCard(prayer: active, nextPrayer: viewModel.nextPrayer)
                                .padding(.horizontal, 16)
                        } else if !viewModel.isLoading {
                            // Before Fajr or after Isha — show next prayer
                            if let next = viewModel.nextPrayer {
                                NextPrayerCard(prayer: next)
                                    .padding(.horizontal, 16)
                            }
                        }

                        // Prayer List — always visible (shows --:-- while loading)
                        PrayerListCard(
                            prayers: viewModel.prayers,
                            isLoading: viewModel.isLoading
                        )
                        .padding(.horizontal, 16)

                        // Location
                        PrayerLocationCard(
                            city:   viewModel.locationDisplay,
                            method: viewModel.methodDisplay
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 64) // Added spacing to match Home Screen navbar clearance
            }
        }
        .task { await viewModel.loadPrayerTimes() }
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)
            Button(action: retry) {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(24)
        .background(Color.appSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Current Prayer Card

struct CurrentPrayerCard: View {
    let prayer: Prayer
    let nextPrayer: Prayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT PRAYER")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(red: 0.27, green: 0.58, blue: 0.43)) // Custom green
                        
                    Text(prayer.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                        
                    Text(prayer.arabicName)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.5)) // Custom gray
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.88, green: 0.9, blue: 0.89)) // Icon bg green
                            .frame(width: 48, height: 48)
                        Image(systemName: prayer.icon)
                            .font(.system(size: 22, weight: .regular))
                            .foregroundColor(Color(red: 0.35, green: 0.6, blue: 0.45))
                    }
                    
                    Text(prayer.time)
                        .font(.system(size: 18, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                }
            }

            if let next = nextPrayer {
                Divider()
                    .background(Color.black.opacity(0.1))
                    .padding(.bottom, 16)
                    
                HStack(spacing: 4) {
                    Text("Next: \(Text(next.name).fontWeight(.semibold).foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))) at \(next.time)")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.5))
                }
            }
        }
        .padding(20)
        .background(Color(red: 0.91, green: 0.92, blue: 0.91)) // Card bg
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Next Prayer Card (Before Fajr / After Isha)

struct NextPrayerCard: View {
    let prayer: Prayer

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("NEXT PRAYER")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.27, green: 0.58, blue: 0.43))
                Text(prayer.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
                Text(prayer.arabicName)
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.5))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Image(systemName: prayer.icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.35, green: 0.6, blue: 0.45))
                Text(prayer.time)
                    .font(.system(size: 18, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.15))
            }
        }
        .padding(20)
        .background(Color(red: 0.91, green: 0.92, blue: 0.91))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Prayer List Card

struct PrayerListCard: View {
    let prayers: [Prayer]
    var isLoading: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                    PrayerRow(prayer: prayer)
                    if index < prayers.count - 1 {
                        Divider().background(Color.appBorder)
                    }
                }
            }
            .opacity(isLoading ? 0.5 : 1.0)

            if isLoading {
                ProgressView()
                    .tint(.appPrimary)
                    .scaleEffect(1.2)
            }
        }
        .background(Color.appSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct PrayerRow: View {
    let prayer: Prayer

    var iconBackground: Color {
        if prayer.isActive {
            return Color(red: 0.88, green: 0.9, blue: 0.89) // active green bg
        }
        return Color(red: 0.89, green: 0.89, blue: 0.89) // inactive gray bg
    }

    var iconColor: Color {
        if prayer.isActive {
            return Color(red: 0.35, green: 0.6, blue: 0.45) // active green icon
        }
        return Color(red: 0.35, green: 0.38, blue: 0.42) // inactive dark gray icon
    }

    var nameColor: Color {
        if prayer.isActive {
            return Color(red: 0.35, green: 0.6, blue: 0.45) // active green text
        }
        return Color(red: 0.2, green: 0.22, blue: 0.28) // deep gray text
    }

    var rowBackgroundColor: Color {
        if prayer.isActive {
            return Color(red: 0.91, green: 0.92, blue: 0.91) // active card bg
        }
        return Color.clear // match location tile background
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 40, height: 40)
                Image(systemName: prayer.icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(prayer.name)
                    .font(.system(size: 16, weight: prayer.isActive ? .semibold : .medium))
                    .foregroundColor(nameColor)

                Text(prayer.arabicName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.5))
            }

            Spacer()

            HStack(spacing: 12) {
                Text(prayer.time)
                    .font(.system(size: 14, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(nameColor)

                if prayer.isPassed {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.82, green: 0.91, blue: 0.85)) // checkmark bg
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.35, green: 0.6, blue: 0.45)) // checkmark color
                    }
                } else if prayer.isActive {
                    ZStack {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 20, height: 20)
                        Circle()
                            .fill(Color(red: 0.35, green: 0.6, blue: 0.45))
                            .frame(width: 8, height: 8)
                    }
                } else {
                    // Empty space for un-passed items to keep alignment
                    Spacer().frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(rowBackgroundColor)
    }
}

// MARK: - Location Card

struct PrayerLocationCard: View {
    let city: String
    let method: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appSecondary)
                    .frame(width: 40, height: 40)
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 16))
                    .foregroundColor(.appMutedForeground)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(city.isEmpty ? "Location not set" : city)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appForeground)
                Text(method.isEmpty ? "—" : method)
                    .font(.system(size: 12))
                    .foregroundColor(.appMutedForeground)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(Color.appSecondary)
                    .frame(width: 32, height: 32)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.appMutedForeground)
            }
        }
        .padding(16)
        .background(Color.appSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
