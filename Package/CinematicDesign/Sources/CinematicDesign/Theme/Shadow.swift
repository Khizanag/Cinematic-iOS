import SwiftUI

// MARK: - Shadow
extension DesignSystem {
    public enum Shadow {
        case subtle
        case card
        case elevated

        var radius: CGFloat {
            switch self {
            case .subtle: 4
            case .card: 10
            case .elevated: 20
            }
        }

        var yOffset: CGFloat {
            switch self {
            case .subtle: 2
            case .card: 6
            case .elevated: 12
            }
        }

        var opacity: Double {
            switch self {
            case .subtle: 0.12
            case .card: 0.18
            case .elevated: 0.24
            }
        }
    }
}

// MARK: - Shadow modifier
extension View {
    public func designShadow(_ shadow: DesignSystem.Shadow) -> some View {
        self.shadow(
            color: .black.opacity(shadow.opacity),
            radius: shadow.radius,
            x: 0,
            y: shadow.yOffset,
        )
    }
}
