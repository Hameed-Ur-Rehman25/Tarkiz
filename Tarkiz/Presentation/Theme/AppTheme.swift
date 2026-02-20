import SwiftUI

struct AppTheme {
    // MARK: - Colors
    static let primaryColor = Color("AppPrimaryColor") // Ensure these are in Assets
    static let secondaryColor = Color("AppSecondaryColor")
    static let errorColor = Color.red
    static let backgroundColor = Color("BackgroundColor")
    static let sageGreen = Color("SageGreen")
    static let surfaceColor = Color("SurfaceColor")
    static let beigeBackground = Color("BeigeBackground")
    
    // MARK: - Spacing
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }
}

// MARK: - Typography
// Placeholder for custom fonts, using system fonts for now
struct Typography {
    static let title = Font.system(size: 28, weight: .bold)
    static let heading = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 12, weight: .regular)
    static let button = Font.system(size: 16, weight: .bold)
}
