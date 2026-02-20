import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.label)
                            .font(.system(size: 15, weight: selectedTab == tab ? .bold : .medium))
                            .foregroundColor(selectedTab == tab ? Color.primary.opacity(0.8) : Color.primary.opacity(0.4))
                        
                        // Active Indicator Dot
                        Circle()
                            .fill(selectedTab == tab ? Color.primary.opacity(0.8) : Color.clear)
                            .frame(width: 3.5, height: 3.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
            }
        }
        .padding(.bottom, 20) // Adjust for home indicator
        .background(
            Color.appBackground
                .ignoresSafeArea()
        )
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
}
