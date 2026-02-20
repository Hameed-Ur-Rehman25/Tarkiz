import SwiftUI
import Combine

// MARK: - Data Models (Onboarding specific)

struct OnboardingCalculationMethod: Identifiable, Hashable {
    let id: String
    let name: String
    let description: String
    let region: String
}

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

private let onboardingCalculationMethods: [OnboardingCalculationMethod] = [
    .init(id: "mwl",     name: "Muslim World League",         description: "Fajr: 18°, Isha: 17°",    region: "Europe, Far East"),
    .init(id: "isna",    name: "ISNA",                        description: "Fajr: 15°, Isha: 15°",    region: "North America"),
    .init(id: "egypt",   name: "Egyptian General Authority",   description: "Fajr: 19.5°, Isha: 17.5°", region: "Africa, Middle East"),
    .init(id: "makkah",  name: "Umm al-Qura",                 description: "Fajr: 18.5°, Isha: 90min", region: "Arabian Peninsula"),
    .init(id: "karachi", name: "University of Karachi",        description: "Fajr: 18°, Isha: 18°",    region: "Pakistan, South Asia"),
]

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
    case welcome, location, method, blocklist, nfc, complete
}

enum NFCScanState {
    case idle, scanning, success
}

class OnboardingFlowViewModel: ObservableObject {
    @Published var step: OnboardingStep = .welcome
    @Published var selectedLocation: OnboardingLocationOption?
    @Published var selectedMethod: OnboardingCalculationMethod?
    @Published var apps: [OnboardingAppItem] = onboardingDefaultApps
    @Published var nfcState: NFCScanState = .idle

    var blockedCount: Int { apps.filter(\.blocked).count }

    func toggleApp(_ id: String) {
        Haptics.impact(.light)
        if let idx = apps.firstIndex(where: { $0.id == id }) {
            apps[idx].blocked.toggle()
        }
    }

    func selectLocation(_ loc: OnboardingLocationOption) {
        Haptics.impact(.light)
        selectedLocation = loc
    }

    func selectMethod(_ m: OnboardingCalculationMethod) {
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
}

// MARK: - Root Flow

struct OnboardingFlow: View {
    var onComplete: () -> Void
    @StateObject private var vm = OnboardingFlowViewModel()

    var body: some View {
        Group {
            switch vm.step {
            case .welcome:   WelcomeStep(vm: vm, onSkip: onComplete)
            case .location:  LocationStep(vm: vm)
            case .method:    MethodStep(vm: vm)
            case .blocklist: BlocklistStep(vm: vm)
            case .nfc:       NFCStep(vm: vm)
            case .complete:  CompleteStep(vm: vm, onFinish: onComplete)
            }
        }
        .transition(.opacity)
    }
}

// MARK: - Shared Sub-views

/// Floating illustration box with corner brackets
private struct IllustrationBox<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.appCard)
                .shadow(color: .black.opacity(0.12), radius: 25, y: 10)
                .frame(width: 128, height: 128)

            content

            CornerBrackets(size: 148, inset: 0, bracketLength: 20, cornerRadius: 8)
                .stroke(Color.appMutedForeground.opacity(0.3), lineWidth: 2)
                .frame(width: 148, height: 148)
        }
    }
}

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

                IllustrationBox { Text("🕌").font(.system(size: 48)) }

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



// MARK: - Step 2: Location

private struct LocationStep: View {
    @ObservedObject var vm: OnboardingFlowViewModel

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

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appPrimary.opacity(0.15))
                            .frame(width: 48, height: 48)
                        Image(systemName: "location.fill")
                            .foregroundColor(.appPrimary)
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
                .padding(.bottom, 12)

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
                        ForEach(onboardingCalculationMethods) { method in
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

    var body: some View {
        VStack(spacing: 0) {
            Text("Block the apps\nthat you select")
                .font(.system(size: 32, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.appForeground)
                .padding(.top, 60)
                .padding(.bottom, 24)

            VStack(spacing: 0) {
                HStack { BackButton { vm.goBack() }; Spacer() }
                    .padding(.bottom, 12)

                Text("\(vm.blockedCount) distraction\(vm.blockedCount != 1 ? "s" : "") selected")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appForeground)
                    .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 0) {
                        let blocked = vm.apps.filter(\.blocked)
                        ForEach(Array(blocked.enumerated()), id: \.element.id) { idx, app in
                            Button { vm.toggleApp(app.id) } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.appSecondary)
                                            .frame(width: 48, height: 48)
                                        Text(app.icon).font(.system(size: 24))
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(app.name).font(.system(size: 14, weight: .medium)).foregroundColor(.appForeground)
                                        if let avg = app.dailyAverage {
                                            Text("Daily average : \(avg)").font(.system(size: 12)).foregroundColor(.appMutedForeground)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                            }
                            if idx < blocked.count - 1 {
                                Divider().background(Color.appBorder)
                            }
                        }

                        let unblocked = vm.apps.filter { !$0.blocked }
                        if !unblocked.isEmpty {
                            Divider().background(Color.appBorder).padding(.vertical, 4)
                            ForEach(Array(unblocked.enumerated()), id: \.element.id) { idx, app in
                                Button { vm.toggleApp(app.id) } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.appSecondary)
                                                .frame(width: 48, height: 48)
                                            Text(app.icon).font(.system(size: 24))
                                        }
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(app.name).font(.system(size: 14, weight: .medium)).foregroundColor(.appForeground)
                                            if let avg = app.dailyAverage {
                                                Text("Daily average : \(avg)").font(.system(size: 12)).foregroundColor(.appMutedForeground)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.appMutedForeground)
                                    }
                                    .padding(.vertical, 12)
                                    .opacity(0.6)
                                }
                                if idx < unblocked.count - 1 {
                                    Divider().background(Color.appBorder)
                                }
                            }
                        }
                    }
                }

                OnboardingPrimaryButton(title: "Complete setup") { vm.advance() }
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

            IllustrationBox {
                Text("NFC")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.appMutedForeground)
            }

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

            OnboardingPrimaryButton(title: "Start Using Tarkiz") { onFinish() }
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
