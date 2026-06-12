import SwiftUI
import UIKit

// MARK: - Appearance-aware hex initializer
extension Color {
    /// A dynamic color that resolves per appearance — Dark Mode support is
    /// built into every token, not bolted on per screen.
    ///
    /// UIKit resolves dynamic providers on arbitrary threads (SwiftUI's
    /// AsyncRenderer included). This package defaults to MainActor isolation,
    /// so the provider must opt out via `@Sendable` — an implicitly isolated
    /// closure here traps with EXC_BREAKPOINT the moment a color resolves
    /// off the main thread.
    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { @Sendable traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

// MARK: - Hex components
nonisolated private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1,
        )
    }
}
