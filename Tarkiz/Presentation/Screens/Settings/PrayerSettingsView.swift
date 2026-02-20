import SwiftUI
import Combine
import CoreLocation

// MARK: - PrayerSettingsViewModel

class PrayerSettingsViewModel: ObservableObject {
    @Published var selectedLocation: String = "New York, USA"
    @Published var selectedMethod: String = "Muslim World League"
    @Published var fajrAdjust: Int = 0
    @Published var dhuhrAdjust: Int = 0
    @Published var asrAdjust: Int = 0
    @Published var maghribAdjust: Int = 0
    @Published var ishaAdjust: Int = 0
    @Published var asrStandard: String = "Shafi'i"

    let methods = [
        "Muslim World League",
        "ISNA",
        "Egyptian General Authority",
        "Umm al-Qura",
        "University of Karachi",
    ]

    let asrStandards = ["Shafi'i", "Hanafi"]

    func detectLocation() {
        // In a real app, use LocationManager + CLGeocoder
        selectedLocation = "New York, USA"
    }
}

// MARK: - PrayerSettingsView

struct PrayerSettingsView: View {
    @StateObject private var viewModel = PrayerSettingsViewModel()
    @EnvironmentObject var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Header
                        HStack {
                            Button { coordinator.pop() } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.appSecondary)
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.appMutedForeground)
                                }
                            }
                            Spacer()
                            Text("Prayer Settings")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appForeground)
                            Spacer().frame(width: 40)
                        }
                        .padding(.top, 56)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)

                        // Location Section
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Location")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)

                                HStack {
                                    Image(systemName: "mappin.and.ellipse")
                                        .foregroundColor(.appPrimary)
                                    Text(viewModel.selectedLocation)
                                        .font(.system(size: 15))
                                        .foregroundColor(.appForeground)
                                    Spacer()
                                }

                                Button { viewModel.detectLocation() } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "location.fill")
                                        Text("Detect Location")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appPrimary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Calculation Method
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Calculation Method")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)

                                VStack(spacing: 8) {
                                    ForEach(viewModel.methods, id: \.self) { method in
                                        Button { viewModel.selectedMethod = method } label: {
                                            HStack {
                                                Text(method)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(viewModel.selectedMethod == method ? .appPrimary : .appForeground)
                                                Spacer()
                                                if viewModel.selectedMethod == method {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.appPrimary)
                                                }
                                            }
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(viewModel.selectedMethod == method ? Color.appPrimary.opacity(0.08) : Color.appSecondary.opacity(0.5))
                                            )
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Asr Standard
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Asr Calculation")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)

                                HStack(spacing: 8) {
                                    ForEach(viewModel.asrStandards, id: \.self) { standard in
                                        Button { viewModel.asrStandard = standard } label: {
                                            Text(standard)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(viewModel.asrStandard == standard ? .white : .appForeground)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(viewModel.asrStandard == standard ? Color.appPrimary : Color.appSecondary.opacity(0.5))
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // Time Adjustments
                        SettingsSection {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Time Adjustments")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.appForeground)
                                Text("Fine tune calculated times in minutes")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appMutedForeground)

                                TimeAdjustRow(label: "Fajr",    value: $viewModel.fajrAdjust)
                                Divider().background(Color.appBorder)
                                TimeAdjustRow(label: "Dhuhr",   value: $viewModel.dhuhrAdjust)
                                Divider().background(Color.appBorder)
                                TimeAdjustRow(label: "Asr",     value: $viewModel.asrAdjust)
                                Divider().background(Color.appBorder)
                                TimeAdjustRow(label: "Maghrib", value: $viewModel.maghribAdjust)
                                Divider().background(Color.appBorder)
                                TimeAdjustRow(label: "Isha",    value: $viewModel.ishaAdjust)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .background(Color.appCard)
                .clipShape(
                    RoundedCornerShape(radius: 56, corners: [.bottomLeft, .bottomRight])
                )
                .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Time Adjust Row

struct TimeAdjustRow: View {
    let label: String
    @Binding var value: Int

    var formattedValue: String {
        value == 0 ? "0 min" : (value > 0 ? "+\(value) min" : "\(value) min")
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appForeground)
            Spacer()
            HStack(spacing: 12) {
                Button { if value > -30 { value -= 1 } } label: {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.appMutedForeground)
                }
                Text(formattedValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appForeground)
                    .monospacedDigit()
                    .frame(width: 56, alignment: .center)
                Button { if value < 30 { value += 1 } } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.appMutedForeground)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
