import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(AppTheme.primaryColor)
            Text("Hello, world!")
                .font(Typography.heading)
            
            CustomButton(title: "Test Button", action: {
                Logger.shared.info("Button tapped")
            })
            .padding()
        }
        .padding()
        .background(AppTheme.backgroundColor)
    }
}

#Preview {
    ContentView()
}
