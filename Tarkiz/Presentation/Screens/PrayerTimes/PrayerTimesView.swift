import SwiftUI
import Combine

// MARK: - Data Model

struct Prayer: Identifiable {
    let id = UUID()
    let name: String
    let arabicName: String
    let time: String
    let icon: String
    var isActive: Bool = false
    var isPassed: Bool = false
}

// MARK: - PrayerTimesViewModel

class PrayerTimesViewModel: ObservableObject {
    @Published var prayers: [Prayer] = [
        Prayer(name: "Fajr",    arabicName: "الفجر",   time: "5:12 AM",  icon: "moon.fill",          isPassed: true),
        Prayer(name: "Sunrise", arabicName: "الشروق",  time: "6:45 AM",  icon: "sunrise.fill",       isPassed: true),
        Prayer(name: "Dhuhr",   arabicName: "الظهر",   time: "12:30 PM", icon: "sun.max.fill",       isActive: true),
        Prayer(name: "Asr",     arabicName: "العصر",   time: "3:45 PM",  icon: "cloud.sun.fill"),
        Prayer(name: "Maghrib", arabicName: "المغرب",  time: "6:15 PM",  icon: "sunset.fill"),
        Prayer(name: "Isha",    arabicName: "العشاء",  time: "7:45 PM",  icon: "sparkles"),
    ]

    var activePrayer: Prayer? { prayers.first { $0.isActive } }
    var nextPrayer: Prayer? { prayers.first { !$0.isPassed && !$0.isActive } }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d"
        return f.string(from: Date()).uppercased()
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
                        }
                        .padding(.top, 32)
                        .padding(.bottom, 8)

                        // Current Prayer Card
                        if let active = viewModel.activePrayer {
                            CurrentPrayerCard(prayer: active, nextPrayer: viewModel.nextPrayer)
                                .padding(.horizontal, 16)
                        }

                        // Prayer List
                        PrayerListCard(prayers: viewModel.prayers)
                            .padding(.horizontal, 16)

                        // Location
                        PrayerLocationCard()
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                    }
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 64)
            }
        }
    }
}

// MARK: - Current Prayer Card

struct CurrentPrayerCard: View {
    let prayer: Prayer
    let nextPrayer: Prayer?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT PRAYER")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.appPrimary)
                    Text(prayer.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.appForeground)
                    Text(prayer.arabicName)
                        .font(.system(size: 14))
                        .foregroundColor(.appMutedForeground)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.appPrimary.opacity(0.1))
                            .frame(width: 48, height: 48)
                        Image(systemName: prayer.icon)
                            .font(.system(size: 22))
                            .foregroundColor(.appPrimary)
                    }
                    Text(prayer.time)
                        .font(.system(size: 18, weight: .semibold))
                        .monospacedDigit()
                        .foregroundColor(.appForeground)
                }
            }

            if let next = nextPrayer {
                Divider()
                    .background(Color.appPrimary.opacity(0.2))
                    .padding(.top, 16)
                Text("Next: \(Text(next.name).fontWeight(.medium).foregroundColor(.appForeground)) at \(next.time)")
                    .font(.system(size: 14))
                    .foregroundColor(.appMutedForeground)
            }
        }
        .padding(20)
        .background(Color.appPrimary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Prayer List Card

struct PrayerListCard: View {
    let prayers: [Prayer]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(prayers.enumerated()), id: \.element.id) { index, prayer in
                PrayerRow(prayer: prayer)
                if index < prayers.count - 1 {
                    Divider().background(Color.appBorder)
                }
            }
        }
        .background(Color.appSecondary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct PrayerRow: View {
    let prayer: Prayer

    var iconBackground: Color {
        if prayer.isPassed { return .appMuted }
        if prayer.isActive { return .appPrimary.opacity(0.1) }
        return .appSecondary
    }

    var iconColor: Color {
        if prayer.isPassed { return .appMutedForeground }
        if prayer.isActive { return .appPrimary }
        return .appForeground
    }

    var nameColor: Color {
        if prayer.isPassed { return .appMutedForeground }
        if prayer.isActive { return .appPrimary }
        return .appForeground
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
                    .font(.system(size: 12))
                    .foregroundColor(.appMutedForeground)
            }

            Spacer()

            HStack(spacing: 10) {
                Text(prayer.time)
                    .font(.system(size: 14, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(nameColor)

                if prayer.isPassed {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
                if prayer.isActive {
                    Circle()
                        .fill(Color.appPrimary)
                        .frame(width: 8, height: 8)
                        .pulseAnimation()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(prayer.isActive ? Color.appPrimary.opacity(0.05) : Color.clear)
    }
}

// MARK: - Location Card

struct PrayerLocationCard: View {
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
                Text("New York, USA")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appForeground)
                Text("Muslim World League")
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
