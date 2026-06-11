import SwiftUI

// MARK: - Motion
extension DesignSystem {
    public enum Motion {
        public static let quick = Animation.easeInOut(duration: 0.2)
        public static let snappy = Animation.snappy(duration: 0.3, extraBounce: 0.05)
        public static let bouncy = Animation.spring(response: 0.45, dampingFraction: 0.72)
    }
}
