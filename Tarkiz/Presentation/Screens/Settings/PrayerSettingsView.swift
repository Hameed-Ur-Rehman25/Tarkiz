import SwiftUI
import Combine
import CoreLocation

// MARK: - PrayerSettingsViewModel

class PrayerSettingsViewModel: ObservableObject {
    private let settings = UserSettings.shared
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    // Location
    @Published var locationDisplay: String = ""
    @Published var isDetectingLocation: Bool = false

    // Method
    @Published var selectedMethodId: Int = 3

    // Asr juristic school (0 = Shafi'i, 1 = Hanafi)
    @Published var asrJuristic: Int = 0

    // Time adjustments
    @Published var fajrAdjust: Int = 0
    @Published var dhuhrAdjust: Int = 0
    @Published var asrAdjust: Int = 0
    @Published var maghribAdjust: Int = 0
    @Published var ishaAdjust: Int = 0

    let methods: [CalculationMethod] = allCalculationMethods
    let asrStandards = ["Shafi'i", "Hanafi"]

    init() {
        loadFromSettings()
        observeLocation()
    }

    // MARK: - Load

    func loadFromSettings() {
        locationDisplay  = settings.locationCity.isEmpty
                             ? "Not set"
                             : "\(settings.locationCity), \(settings.locationCountry)"
        selectedMethodId = settings.calculationMethodId
        asrJuristic      = settings.asrJuristic
        fajrAdjust       = settings.fajrAdjust
        dhuhrAdjust      = settings.dhuhrAdjust
        asrAdjust        = settings.asrAdjust
        maghribAdjust    = settings.maghribAdjust
        ishaAdjust       = settings.ishaAdjust
    }

    // MARK: - Save

    func saveSettings() {
        if let method = methods.first(where: { $0.id == selectedMethodId }) {
            settings.calculationMethodId   = method.id
            settings.calculationMethodName = method.name
        }
        settings.asrJuristic   = asrJuristic
        settings.fajrAdjust    = fajrAdjust
        settings.dhuhrAdjust   = dhuhrAdjust
        settings.asrAdjust     = asrAdjust
        settings.maghribAdjust = maghribAdjust
        settings.ishaAdjust    = ishaAdjust
        // Bust cache so Prayer Times screen re-fetches with new settings
        DIContainer.shared.prayerTimesRepository.invalidateCache()
    }

    // MARK: - Detect Location

    func detectLocation() {
        isDetectingLocation = true
        locationManager.requestPermission()
    }

    private func observeLocation() {
        // When GPS resolves, save to UserSettings
        locationManager.$fetchedCity
            .compactMap { $0 }
            .combineLatest(
                locationManager.$fetchedCountry.compactMap { $0 },
                locationManager.$latitude.compactMap { $0 },
                locationManager.$longitude.compactMap { $0 }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] city, country, lat, lon in
                guard let self else { return }
                self.settings.locationCity    = city
                self.settings.locationCountry = country
                self.settings.latitude        = lat
                self.settings.longitude       = lon
                self.locationDisplay          = "\(city), \(country)"
                self.isDetectingLocation      = false
                // Bust cache so Prayer Times re-fetches
                DIContainer.shared.prayerTimesRepository.invalidateCache()
            }
            .store(in: &cancellables)
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
                                    Text(viewModel.locationDisplay)
                                        .font(.system(size: 15))
                                        .foregroundColor(.appForeground)
                                    Spacer()
                                }

                                Button {
                                    viewModel.detectLocation()
                                } label: {
                                    HStack(spacing: 8) {
                                        if viewModel.isDetectingLocation {
                                            ProgressView().tint(.appPrimary)
                                        } else {
                                            Image(systemName: "location.fill")
                                        }
                                        Text(viewModel.isDetectingLocation ? "Detecting..." : "Detect Location")
                                    }
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.appPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.appPrimary.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                                .disabled(viewModel.isDetectingLocation)
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
                                    ForEach(viewModel.methods) { method in
                                        Button { viewModel.selectedMethodId = method.id } label: {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(method.name)
                                                        .font(.system(size: 14))
                                                        .foregroundColor(viewModel.selectedMethodId == method.id ? .appPrimary : .appForeground)
                                                    Text(method.region)
                                                        .font(.system(size: 11))
                                                        .foregroundColor(.appMutedForeground)
                                                }
                                                Spacer()
                                                if viewModel.selectedMethodId == method.id {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.appPrimary)
                                                }
                                            }
                                            .padding(12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(viewModel.selectedMethodId == method.id ? Color.appPrimary.opacity(0.08) : Color.appSecondary.opacity(0.5))
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
                                    ForEach(Array(viewModel.asrStandards.enumerated()), id: \.offset) { idx, standard in
                                        Button { viewModel.asrJuristic = idx } label: {
                                            Text(standard)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(viewModel.asrJuristic == idx ? .white : .appForeground)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(viewModel.asrJuristic == idx ? Color.appPrimary : Color.appSecondary.opacity(0.5))
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
        .onDisappear {
            viewModel.saveSettings()
        }
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
