import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    
    var body: some View {
        if viewModel.showHome {
            // Navigate to main app content (placeholder for now)
            // In a real app, this would switch the root view controller or environment object
            LoginView()
        } else {
            ZStack {
                AppTheme.backgroundColor.ignoresSafeArea()
                
                VStack {
                    HStack {
                        Spacer()
                        Button("Skip") {
                            viewModel.skip()
                        }
                        .foregroundColor(AppTheme.secondaryColor)
                        .padding()
                    }
                    
                    TabView(selection: $viewModel.currentPage) {
                        ForEach(0..<viewModel.pages.count, id: \.self) { index in
                            OnboardingPageView(page: viewModel.pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    HStack(spacing: 8) {
                        ForEach(0..<viewModel.pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == viewModel.currentPage ? AppTheme.primaryColor : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    CustomButton(title: viewModel.currentPage == viewModel.pages.count - 1 ? "Get Started" : "Next") {
                        viewModel.nextPage()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(AppTheme.primaryColor)
            
            Text(page.title)
                .font(Typography.title)
                .foregroundColor(AppTheme.primaryColor)
            
            Text(page.description)
                .font(Typography.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}
