import SwiftUI
import UIKit

// MARK: - Color Tokens

extension Color {
    static let appBackground      = Color(hue: 0.08, saturation: 0.05, brightness: 0.96)
    static let appCard            = Color.white
    static let appForeground      = Color(hue: 0, saturation: 0, brightness: 0.12)
    static let appMutedForeground = Color(hue: 0, saturation: 0, brightness: 0.45)
    static let appSecondary       = Color(hue: 0.08, saturation: 0.04, brightness: 0.93)
    static let appMuted           = Color(hue: 0, saturation: 0, brightness: 0.88)
    static let appBorder          = Color(hue: 0, saturation: 0, brightness: 0.88)
    static let appPrimary         = Color(hue: 0.37, saturation: 0.48, brightness: 0.44) // sage green
    static let appAccent          = Color(hue: 0.37, saturation: 0.42, brightness: 0.50) // soft sage
}

// MARK: - RoundedCornerShape

/// Rounds only the specified corners of a rectangle.
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - CornerBrackets

/// Draws decorative corner brackets inside a square frame.
struct CornerBrackets: Shape {
    var size: CGFloat
    var inset: CGFloat
    var bracketLength: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let s = size
        let i = inset
        let l = bracketLength
        let r = cornerRadius

        // Top-left
        p.move(to: CGPoint(x: i, y: i + l))
        p.addLine(to: CGPoint(x: i, y: i + r))
        p.addQuadCurve(to: CGPoint(x: i + r, y: i), control: CGPoint(x: i, y: i))
        p.addLine(to: CGPoint(x: i + l, y: i))

        // Top-right
        p.move(to: CGPoint(x: s - i - l, y: i))
        p.addLine(to: CGPoint(x: s - i - r, y: i))
        p.addQuadCurve(to: CGPoint(x: s - i, y: i + r), control: CGPoint(x: s - i, y: i))
        p.addLine(to: CGPoint(x: s - i, y: i + l))

        // Bottom-left
        p.move(to: CGPoint(x: i, y: s - i - l))
        p.addLine(to: CGPoint(x: i, y: s - i - r))
        p.addQuadCurve(to: CGPoint(x: i + r, y: s - i), control: CGPoint(x: i, y: s - i))
        p.addLine(to: CGPoint(x: i + l, y: s - i))

        // Bottom-right
        p.move(to: CGPoint(x: s - i, y: s - i - l))
        p.addLine(to: CGPoint(x: s - i, y: s - i - r))
        p.addQuadCurve(to: CGPoint(x: s - i - r, y: s - i), control: CGPoint(x: s - i, y: s - i))
        p.addLine(to: CGPoint(x: s - i - l, y: s - i))

        return p
    }
}

// MARK: - PulseModifier

/// Applies a repeating opacity pulse animation.
struct PulseModifier: ViewModifier {
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .opacity(animate ? 0.5 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animate)
            .onAppear { animate = true }
    }
}

extension View {
    func pulseAnimation() -> some View {
        modifier(PulseModifier())
    }
}

// MARK: - Haptics Helpers

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
