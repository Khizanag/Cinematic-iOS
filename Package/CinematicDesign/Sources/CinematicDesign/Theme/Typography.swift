import SwiftUI

// MARK: - Font
extension DesignSystem {
    public enum Font {
        // Text styles — scale automatically with Dynamic Type.
        public static let largeTitle = SwiftUI.Font.system(.largeTitle, design: .rounded).weight(.bold)
        public static let title = SwiftUI.Font.system(.title, design: .rounded).weight(.bold)
        public static let title2 = SwiftUI.Font.system(.title2, design: .rounded).weight(.semibold)
        public static let title3 = SwiftUI.Font.system(.title3, design: .rounded).weight(.semibold)
        public static let headline = SwiftUI.Font.system(.headline, design: .rounded)
        public static let body = SwiftUI.Font.system(.body, design: .rounded)
        public static let callout = SwiftUI.Font.system(.callout, design: .rounded)
        public static let subheadline = SwiftUI.Font.system(.subheadline, design: .rounded)
        public static let footnote = SwiftUI.Font.system(.footnote, design: .rounded)
        public static let caption = SwiftUI.Font.system(.caption, design: .rounded)
    }
}
