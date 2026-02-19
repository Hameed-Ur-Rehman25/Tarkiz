import SwiftUI

struct AppItem: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let usage: String
}

struct BlockAppsView: View {
    @ObservedObject var viewModel: SetupViewModel
    @State private var selectedApps: Set<UUID> = []
    
    let apps = [
        AppItem(name: "TikTok", iconName: "music.note", usage: "1h 32m"),
        AppItem(name: "Instagram", iconName: "camera.fill", usage: "1h 53m"),
        AppItem(name: "Facebook", iconName: "person.2.fill", usage: "0h 31m"),
        AppItem(name: "Twitter", iconName: "bird.fill", usage: "0h 45m"),
        AppItem(name: "Snapchat", iconName: "bell.fill", usage: "0h 20m")
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Button(action: {
                    withAnimation {
                        viewModel.previousStep()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Block the apps\nthat you select")
                .font(Typography.title)
                .multilineTextAlignment(.center)
                .foregroundColor(AppTheme.primaryColor)
            
            Text("\(selectedApps.count) distractions selected")
                .font(Typography.heading)
                .foregroundColor(AppTheme.primaryColor)
                .padding(.vertical, 10)
            
            // Apps List
            List(apps) { app in
                Button(action: {
                    if selectedApps.contains(app.id) {
                        selectedApps.remove(app.id)
                    } else {
                        selectedApps.insert(app.id)
                    }
                }) {
                    HStack {
                        Image(systemName: app.iconName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(AppTheme.primaryColor)
                        
                        VStack(alignment: .leading) {
                            Text(app.name)
                                .font(Typography.body.weight(.semibold))
                                .foregroundColor(AppTheme.primaryColor)
                            Text("Daily average: \(app.usage)")
                                .font(Typography.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        if selectedApps.contains(app.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppTheme.sageGreen)
                        }
                    }
                    .padding(.vertical, 5)
                }
            }
            .listStyle(PlainListStyle())
            
            Button("+ Add more apps to block") {
                // Placeholder action
            }
            .foregroundColor(AppTheme.sageGreen)
            .font(Typography.body.weight(.medium))
            .padding(.bottom, 10)
            
            // Complete Setup Button
            Button(action: {
                withAnimation {
                     viewModel.nextStep()
                }
            }) {
                Text("Complete setup")
                    .font(Typography.button)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.sageGreen)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(AppTheme.backgroundColor.ignoresSafeArea())
    }
}
