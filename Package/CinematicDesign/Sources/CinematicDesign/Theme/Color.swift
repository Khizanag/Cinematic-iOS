import SwiftUI

// MARK: - Color
extension DesignSystem {
    public enum Color {
        // Brand
        public static let accent = SwiftUI.Color(light: 0x635BF3, dark: 0x8A84FB)
        public static let accentSecondary = SwiftUI.Color(light: 0xF166BD, dark: 0xF98AD0)
        /// The only sanctioned absolute white — text/icons drawn on `accent`.
        public static let onAccent = SwiftUI.Color.white

        // Surfaces
        public static let background = SwiftUI.Color(light: 0xF6F6FB, dark: 0x0B0A12)
        public static let cardBackground = SwiftUI.Color(light: 0xFFFFFF, dark: 0x1C1B27)
        public static let groupedBackground = SwiftUI.Color(light: 0xEFEFF5, dark: 0x141320)
        public static let separator = SwiftUI.Color(light: 0xE2E2EC, dark: 0x2A2A3A)

        // Text
        public static let textPrimary = SwiftUI.Color(light: 0x1A1A2E, dark: 0xF4F4FA)
        public static let textSecondary = SwiftUI.Color(light: 0x5A5A72, dark: 0xA8A8BE)

        // Status
        public static let success = SwiftUI.Color(light: 0x2BB673, dark: 0x47D38A)
        public static let warning = SwiftUI.Color(light: 0xE0A028, dark: 0xF2BC4E)
        public static let danger = SwiftUI.Color(light: 0xE0524E, dark: 0xF3726E)
    }
}
