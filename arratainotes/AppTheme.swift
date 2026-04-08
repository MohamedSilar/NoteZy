import SwiftUI

struct AppTheme {
    // Dynamic Colors based on theme
    static func backgroundColor(for theme: String) -> Color {
        switch theme {
        case "Light": return Color(hex: "F2F2F7")
        case "Dark": return Color(hex: "000000")
        default: return Color(hex: "0F111A") // Purple/Default
        }
    }
    
    static func cardBackgroundColor(for theme: String) -> Color {
        switch theme {
        case "Light": return .white
        case "Dark": return Color(hex: "1C1C1E")
        default: return Color(hex: "1A1D29") // Purple/Default
        }
    }
    
    static func textColor(for theme: String) -> Color {
        switch theme {
        case "Light": return .black
        default: return .white
        }
    }

    static let background = Color(hex: "0F111A")
    static let cardBackground = Color(hex: "1A1D29")
    static let accent = Color(hex: "7B61FF")
    
    // Event Category Colors
    static let workColor = Color(hex: "FF9F0A")
    static let ideasColor = Color(hex: "32ADE6")
    static let personalColor = Color(hex: "FF2D55")
    static let quotesColor = Color(hex: "AF52DE")
    static let folderYellow = Color(hex: "FFCC00")
    
    static let tertiary = Color(hex: "252839")
    static let neutralPill = Color.white.opacity(0.1)
    static let glassBackground = Color.white.opacity(0.05)
    
    // Font Scaling: size is the reference size at base 16pt
    static func rounded(_ size: CGFloat, weight: Font.Weight = .regular, base: CGFloat = 16) -> Font {
        let scaleFactor = base / 16.0
        return .system(size: size * scaleFactor, weight: weight, design: .rounded)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
