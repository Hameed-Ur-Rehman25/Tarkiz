import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var showHome = false
    
    let pages = [
        OnboardingPage(
            title: "Welcome to Tarkiz",
            description: "Your companion for focus, prayer, and mindful living.",
            imageName: "sparkles" // SFSymbol
        ),
        OnboardingPage(
            title: "Stay Focused",
            description: "Block distractions and maintain your flow state with advanced tools.",
            imageName: "eye.slash"
        ),
        OnboardingPage(
            title: "Prayer Times",
            description: "Never miss a prayer with accurate timings and reminders.",
            imageName: "clock"
        ),
        OnboardingPage(
            title: "NFC Integration",
            description: "Unlock your session or phone instantly with NFC tags.",
            imageName: "wave.3.right"
        )
    ]
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    func skip() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        // Save flag to UserDefaults
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        showHome = true
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
}
