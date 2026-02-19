import SwiftUI

struct CustomButton: View {
    let title: String
    let style: ButtonStyle
    let isLoading: Bool
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary, destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary: return AppTheme.primaryColor
            case .secondary: return AppTheme.secondaryColor
            case .destructive: return AppTheme.errorColor
            }
        }
    }
    
    init(
        title: String,
        style: ButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(Typography.button)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(style.backgroundColor)
            .cornerRadius(AppTheme.Spacing.medium)
        }
        .disabled(isLoading)
    }
}
