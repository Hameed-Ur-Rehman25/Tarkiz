import SwiftUI
import CoreLocation
import Combine
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Data Models (Onboarding specific)

struct OnboardingLocationOption: Identifiable, Hashable {
    var id: String { city }
    let city: String
    let country: String
    let flag: String
}

struct OnboardingAppItem: Identifiable {
    let id: String
    let name: String
    let icon: String
    let category: String
    var blocked: Bool
    var dailyAverage: String?
}

// MARK: - Static Data

private let onboardingPopularLocations: [OnboardingLocationOption] = [
    .init(city: "New York",  country: "USA",          flag: "🇺🇸"),
    .init(city: "London",    country: "UK",           flag: "🇬🇧"),
    .init(city: "Dubai",     country: "UAE",          flag: "🇦🇪"),
    .init(city: "Makkah",    country: "Saudi Arabia", flag: "🇸🇦"),
    .init(city: "Cairo",     country: "Egypt",        flag: "🇪🇬"),
    .init(city: "Istanbul",  country: "Turkey",       flag: "🇹🇷"),
    .init(city: "Karachi",   country: "Pakistan",     flag: "🇵🇰"),
    .init(city: "Toronto",   country: "Canada",       flag: "🇨🇦"),
]

private let onboardingDefaultApps: [OnboardingAppItem] = [
    .init(id: "tiktok",    name: "TikTok",      icon: "🎵", category: "Social",        blocked: true,  dailyAverage: "1h 32m"),
    .init(id: "instagram", name: "Instagram",    icon: "📷", category: "Social",        blocked: true,  dailyAverage: "1h 53m"),
    .init(id: "facebook",  name: "Facebook",     icon: "👤", category: "Social",        blocked: true,  dailyAverage: "0h 31m"),
    .init(id: "twitter",   name: "X (Twitter)",  icon: "🐦", category: "Social",        blocked: false, dailyAverage: "0h 45m"),
    .init(id: "youtube",   name: "YouTube",      icon: "▶️", category: "Entertainment", blocked: false, dailyAverage: "2h 10m"),
    .init(id: "netflix",   name: "Netflix",      icon: "🎬", category: "Entertainment", blocked: false),
    .init(id: "reddit",    name: "Reddit",       icon: "🔴", category: "Social",        blocked: false),
    .init(id: "candy",     name: "Candy Crush",  icon: "🍬", category: "Games",         blocked: false),
]

// MARK: - ViewModel

enum OnboardingStep: Int, CaseIterable {
    case welcome, notifications, location, method, blocklist, nfc, complete
}

enum NFCScanState {
    case idle, scanning, success
}

class OnboardingFlowViewModel: ObservableObject {
    @Published var step: OnboardingStep = .welcome
    @Published var selectedLocation: OnboardingLocationOption?
    @Published var selectedMethod: CalculationMethod?
    @Published var nfcState: NFCScanState = .idle

    // Coordinates set either via GPS or geocoding a preset city
    var selectedLatitude: Double?
    var selectedLongitude: Double?

    var blockedCount: Int { 
        ScreenTimeService.shared.selection.applicationTokens.count + ScreenTimeService.shared.selection.categoryTokens.count
    }

    func selectLocation(_ loc: OnboardingLocationOption) {
        Haptics.impact(.light)
        selectedLocation = loc
        // Geocode preset city to get lat/lon
        geocodeCity(loc.city, country: loc.country)
    }

    func setGPSLocation(city: String, country: String, lat: Double, lon: Double) {
        selectedLocation = OnboardingLocationOption(city: city, country: country, flag: "📍")
        selectedLatitude  = lat
        selectedLongitude = lon
    }

    func selectMethod(_ m: CalculationMethod) {
        Haptics.impact(.light)
        selectedMethod = m
    }

    func advance() {
        Haptics.impact(.light)
        guard let next = OnboardingStep(rawValue: step.rawValue + 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) { step = next }
    }

    func goBack() {
        guard let prev = OnboardingStep(rawValue: step.rawValue - 1) else { return }
        withAnimation(.easeInOut(duration: 0.35)) { step = prev }
    }

    func startNfcScan() {
        Haptics.impact(.light)
        nfcState = .scanning
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            Haptics.notification(.success)
            self?.nfcState = .success
        }
    }

    /// Persist all onboarding choices to UserSettings so the app can use them.
    func saveSettingsAndComplete() {
        let settings = UserSettings.shared
        if let loc = selectedLocation {
            settings.locationCity    = loc.city
            settings.locationCountry = loc.country
        }
        if let lat = selectedLatitude  { settings.latitude  = lat }
        if let lon = selectedLongitude { settings.longitude = lon }
        if let method = selectedMethod {
            settings.calculationMethodName = method.name
            settings.calculationMethodId   = method.id
        }
        settings.hasCompletedOnboarding = true
        // Invalidate the prayer times cache so fresh data is fetched
        DIContainer.shared.prayerTimesRepository.invalidateCache()
    }

    // MARK: - Private

    private func geocodeCity(_ city: String, country: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString("\(city), \(country)") { [weak self] placemarks, _ in
            guard let coord = placemarks?.first?.location?.coordinate else { return }
            DispatchQueue.main.async {
                self?.selectedLatitude  = coord.latitude
                self?.selectedLongitude = coord.longitude
            }
        }
    }
}

// MARK: - Root Flow

struct OnboardingFlow: View {
    var onComplete: () -> Void
    @StateObject private var vm = OnboardingFlowViewModel()

    var body: some View {
        Group {
            switch vm.step {
            case .welcome:       WelcomeStep(vm: vm, onSkip: onComplete)
            case .notifications: PermissionsStep(vm: vm)
            case .location:      LocationStep(vm: vm)
            case .method:        MethodStep(vm: vm)
            case .blocklist:     BlocklistStep(vm: vm)
            case .nfc:           NFCStep(vm: vm)
            case .complete:      CompleteStep(vm: vm, onFinish: onComplete)
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Shared Sub-views



/// Back button used across steps
private struct BackButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.appMutedForeground)
                .frame(width: 40, height: 40)
                .background(Color.appSecondary)
                .clipShape(Circle())
        }
    }
}

/// Primary full-width button
private struct OnboardingPrimaryButton: View {
    let title: String
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(disabled ? Color.appPrimary.opacity(0.4) : Color.appPrimary)
                )
        }
        .disabled(disabled)
    }
}

// MARK: - Step 1: Welcome

private struct WelcomeStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel
    var onSkip: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Text("Protect your prayer\ntime from distractions")
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.appForeground)
                    .padding(.bottom, 48)

                Image("NFCLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 176, height: 176)

                Spacer()

                // Bottom card — extends flush to screen bottom
                VStack(spacing: 0) {
                    Text("Ready to focus?")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appForeground)
                        .padding(.bottom, 24)

                    OnboardingPrimaryButton(title: "Get Started") { vm.advance() }
                        .padding(.bottom, 12)

                    Button("I'll set up later") { onSkip() }
                        .font(.system(size: 14))
                        .foregroundColor(.appMutedForeground)
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 36)
                    .padding(.bottom, 52)
                    .background(
                        RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                            .fill(Color.appCard)
                            .ignoresSafeArea(edges: .bottom)
                            .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
                    )
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Step 2: Permissions (Notifications & Background)

private struct PermissionsStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel
    @StateObject private var notificationManager = NotificationManager()

    var body: some View {
        VStack(spacing: 0) {
            Text("Stay Updated\n& Accurate")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.top, 60)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                HStack { BackButton { vm.goBack() }; Spacer() }
                    .padding(.bottom, 12)

                // Notifications Card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "bell.badge.fill")
                            .foregroundColor(.appPrimary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Notifications").font(.system(size: 15, weight: .medium)).foregroundColor(.appForeground)
                        Text("Get timely reminders for prayers").font(.system(size: 12)).foregroundColor(.appMutedForeground)
                    }
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appSecondary.opacity(0.3))
                )
                .padding(.bottom, 12)

                // Background Activity Card
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .foregroundColor(.appPrimary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Background Activity").font(.system(size: 15, weight: .medium)).foregroundColor(.appForeground)
                        Text("Keep prayer times synced silently").font(.system(size: 12)).foregroundColor(.appMutedForeground)
                    }
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appSecondary.opacity(0.3))
                )
                .padding(.bottom, 12)

                Spacer()
                
                Button(action: {
                    notificationManager.requestPermission { _ in
                        vm.advance()
                    }
                }) {
                    Text("Enable & Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appPrimary)
                        )
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 36)
            .padding(.bottom, 52)
            .background(
                RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                    .fill(Color.appCard)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
            )
        }
        .ignoresSafeArea(edges: .bottom)
    }
}


// MARK: - Step 2: Location

private struct LocationStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel
    @StateObject private var locationManager = LocationManager()

    let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        VStack(spacing: 0) {
            Text("Set your location\nfor prayer times")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.top, 60)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                HStack { BackButton { vm.goBack() }; Spacer() }
                    .padding(.bottom, 12)

                VStack(spacing: 0) {
                    if let city = locationManager.fetchedCity, let country = locationManager.fetchedCountry {
                        // Display fetched location visually similar to list items
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 6) {
                                Text("📍").font(.system(size: 18))
                                Text(city).font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            Text(country).font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appPrimary)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.appPrimary, lineWidth: 2)
                        )
                    } else {
                        Button {
                            locationManager.requestPermission()
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.appPrimary.opacity(0.15))
                                        .frame(width: 48, height: 48)
                                    if locationManager.isFetching {
                                        ProgressView().tint(.appPrimary)
                                    } else {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(.appPrimary)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Use My Location").font(.system(size: 15, weight: .medium)).foregroundColor(.appPrimary)
                                    Text("Auto-detect via GPS").font(.system(size: 12)).foregroundColor(.appPrimary.opacity(0.7))
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appPrimary.opacity(0.08))
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.appPrimary.opacity(0.2)))
                            )
                        }
                        .disabled(locationManager.isFetching)
                    }
                }
                .padding(.bottom, 12)
                .onChange(of: locationManager.fetchedCity) {
                    if let city = locationManager.fetchedCity,
                       let country = locationManager.fetchedCountry,
                       let lat = locationManager.latitude,
                       let lon = locationManager.longitude {
                        vm.setGPSLocation(city: city, country: country, lat: lat, lon: lon)
                    }
                }

                HStack(spacing: 8) {
                    Rectangle().fill(Color.appBorder).frame(height: 1)
                    Text("or select a city").font(.system(size: 12)).foregroundColor(.appMutedForeground)
                    Rectangle().fill(Color.appBorder).frame(height: 1)
                }
                .padding(.bottom, 12)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(onboardingPopularLocations) { loc in
                            let selected = vm.selectedLocation?.city == loc.city
                            Button { vm.selectLocation(loc) } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text(loc.flag).font(.system(size: 18))
                                        Text(loc.city).font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selected ? .white : .appForeground)
                                    }
                                    Text(loc.country).font(.system(size: 12))
                                        .foregroundColor(selected ? .white.opacity(0.7) : .appMutedForeground)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selected ? Color.appPrimary : Color.appSecondary.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selected ? Color.appPrimary : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                }

                OnboardingPrimaryButton(title: "Continue", disabled: vm.selectedLocation == nil) { vm.advance() }
                    .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
            .background(
                RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                    .fill(Color.appCard)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
            )
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Step 3: Calculation Method

private struct MethodStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Choose calculation\nmethod")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.top, 60)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                HStack { BackButton { vm.goBack() }; Spacer() }
                    .padding(.bottom, 8)

                Text("Based on your region or school of thought")
                    .font(.system(size: 14))
                    .foregroundColor(.appMutedForeground)
                    .padding(.bottom, 12)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(allCalculationMethods) { method in
                            let selected = vm.selectedMethod?.id == method.id
                            Button { vm.selectMethod(method) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(method.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.appForeground)
                                        Spacer()
                                        Circle()
                                            .strokeBorder(selected ? Color.appPrimary : Color.appBorder, lineWidth: 2)
                                            .background(Circle().fill(selected ? Color.appPrimary : Color.clear))
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                selected ? Image(systemName: "checkmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white) : nil
                                            )
                                    }
                                    HStack(spacing: 8) {
                                        Text(method.description)
                                            .font(.system(size: 11))
                                            .foregroundColor(.appMutedForeground)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.appSecondary)
                                            .cornerRadius(6)
                                        Text(method.region)
                                            .font(.system(size: 11))
                                            .foregroundColor(.appPrimary.opacity(0.7))
                                    }
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selected ? Color.appPrimary.opacity(0.04) : Color.appSecondary.opacity(0.5))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selected ? Color.appPrimary : Color.clear, lineWidth: 2)
                                )
                            }
                        }
                    }
                }

                OnboardingPrimaryButton(title: "Continue", disabled: vm.selectedMethod == nil) { vm.advance() }
                    .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
            .background(
                RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                    .fill(Color.appCard)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
            )
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Step 4: Blocklist

private struct BlocklistStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel
    @StateObject private var screenTimeService = ScreenTimeService.shared
    @State private var isPickerPresented = false
    @State private var searchText: String = ""
    @State private var selectedCategory: String = "All"

    private var selectionCount: Int {
        screenTimeService.selection.applicationTokens.count + screenTimeService.selection.categoryTokens.count
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("Block the apps\nthat you select")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.top, 60)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                // Back + counter
                HStack {
                    BackButton { vm.goBack() }
                    Spacer()
                    Text("\(selectionCount) items protected")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.appForeground)
                    Spacer()
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.bottom, 24)

                if screenTimeService.isAuthorized {
                    // Selection Summary Card
                    VStack(spacing: 24) {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.appPrimary)
                            .padding(.top, 20)
                        
                        VStack(spacing: 8) {
                            Text("Screen Protection")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appForeground)
                            
                            Text("Selected apps will be restricted\nduring your focus time.")
                                .font(.system(size: 14))
                                .foregroundColor(.appMutedForeground)
                                .multilineTextAlignment(.center)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SummaryRowCustom(
                                icon: "folder.fill",
                                label: "Categories",
                                value: "\(screenTimeService.selection.categoryTokens.count) selected"
                            )
                            
                            SummaryRowCustom(
                                icon: "app.badge.fill",
                                label: "Individual Apps",
                                value: "\(screenTimeService.selection.applicationTokens.count) selected"
                            )
                        }
                        .padding(20)
                        .background(Color.appSecondary.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Button {
                            isPickerPresented = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text(selectionCount == 0 ? "Select Apps to Block" : "Change Selection")
                            }
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.bottom, 10)
                    }
                    .padding(24)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding(.bottom, 32)
                } else {
                    // Authorization Request Card
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .fill(Color.appPrimary.opacity(0.1))
                                .frame(width: 100, height: 100)
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.appPrimary)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Text("Unlock Protection")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.appForeground)
                            
                            Text("Tarkiz needs your permission to manage app usage and show the app selector.")
                                .font(.system(size: 15))
                                .foregroundColor(.appMutedForeground)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 10)
                        }
                        
                        Button {
                            Task {
                                await screenTimeService.requestAuthorization()
                            }
                        } label: {
                            Text("Allow Access")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.appPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.bottom, 10)
                        
                        Text("This uses Apple's native Screen Time API for safety and privacy.")
                            .font(.system(size: 12))
                            .foregroundColor(.appMutedForeground.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .padding(.bottom, 32)
                }

                Spacer()

                OnboardingPrimaryButton(title: "Complete setup", disabled: selectionCount == 0) {
                    vm.advance()
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
            .background(
                RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                    .fill(Color.appCard)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
            )
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $screenTimeService.selection)
    }
}

private struct SummaryRowCustom: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.appPrimary.opacity(0.1))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.appPrimary)
            }
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.appForeground)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appMutedForeground)
        }
    }
}

// MARK: - Step 5: NFC

private struct NFCStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Tap your tag\nwhenever you\nneed to focus")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.bottom, 48)

            Image("NFCLogo")
                .resizable()
                .scaledToFill()
                .frame(width: 176, height: 176)

            Spacer()

            VStack(spacing: 0) {
                switch vm.nfcState {
                case .idle:
                    Text("Ready to scan")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.appForeground)
                        .padding(.bottom, 24)

                    ZStack {
                        Circle()
                            .strokeBorder(Color.appPrimary, lineWidth: 2)
                            .frame(width: 64, height: 64)
                        Image(systemName: "iphone")
                            .font(.system(size: 28))
                            .foregroundColor(.appPrimary)
                    }
                    .padding(.bottom, 24)

                    OnboardingPrimaryButton(title: "Scan NFC Tag") { vm.startNfcScan() }
                        .padding(.bottom, 12)

                    Button("Skip for now") { vm.advance() }
                        .font(.system(size: 14))
                        .foregroundColor(.appMutedForeground)
                        .padding(.vertical, 8)

                case .scanning:
                    VStack(spacing: 16) {
                        ZStack {
                            ForEach(0..<3) { i in
                                Circle()
                                    .stroke(Color.appPrimary.opacity(0.2), lineWidth: 2)
                                    .frame(width: CGFloat(48 + i * 24), height: CGFloat(48 + i * 24))
                                    .pulseAnimation()
                            }
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "wave.3.right")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                )
                        }
                        .frame(height: 100)

                        Text("Scanning...")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appForeground)

                        Text("Hold the back of your phone near the NFC tag")
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)
                            .multilineTextAlignment(.center)

                        Button("Cancel") { vm.nfcState = .idle }
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)
                            .padding(.top, 8)
                    }

                case .success:
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 64, height: 64)
                            Image(systemName: "checkmark")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }

                        Text("Tag Paired!")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appForeground)

                        Text("Your NFC tag is ready to use")
                            .font(.system(size: 14))
                            .foregroundColor(.appMutedForeground)

                        OnboardingPrimaryButton(title: "Continue") { vm.advance() }
                            .padding(.top, 8)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 36)
            .padding(.bottom, 40)
            .background(
                RoundedCornerShape(radius: 40, corners: [.topLeft, .topRight])
                    .fill(Color.appCard)
                    .ignoresSafeArea(edges: .bottom)
                    .shadow(color: .black.opacity(0.06), radius: 20, y: -5)
            )
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Step 6: Complete

private struct CompleteStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 112, height: 112)
                Text("🎉").font(.system(size: 56))
            }
            .padding(.bottom, 28)

            Text("You're All Set!")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(.appForeground)
                .padding(.bottom, 8)

            Text("Tarkiz is ready to help you\nfocus during prayer times")
                .font(.system(size: 16))
                .foregroundColor(.appMutedForeground)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 16) {
                Text("YOUR SETUP")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.appMutedForeground)
                    .tracking(1)

                SummaryRow(icon: "📍", label: "Location",
                           value: vm.selectedLocation.map { "\($0.city), \($0.country)" } ?? "Not set")
                SummaryRow(icon: "🧭", label: "Method",
                           value: vm.selectedMethod?.name ?? "Not set")
                SummaryRow(icon: "🛡️", label: "Blocked Apps",
                           value: "\(vm.blockedCount) apps")
                SummaryRow(icon: "📡", label: "NFC Tag",
                           value: vm.nfcState == .success ? "Paired" : "Not set up",
                           highlight: vm.nfcState == .success)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appCard)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.appBorder.opacity(0.5)))
            )
            .padding(.horizontal, 32)
            .padding(.bottom, 32)

            Spacer()

            OnboardingPrimaryButton(title: "Start Using Tarkiz") {
                vm.saveSettingsAndComplete()
                onFinish()
            }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .background(Color.appBackground.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String
    var highlight: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Text(icon).font(.system(size: 18))
            Text(label).font(.system(size: 14)).foregroundColor(.appMutedForeground)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium))
                .foregroundColor(highlight ? .green : .appForeground)
        }
    }
}
