import CoreGraphics

// MARK: - Size
extension DesignSystem {
    public enum Size {
        public enum Icon {
            public static let sm: CGFloat = 18
            public static let md: CGFloat = 24
            public static let lg: CGFloat = 32
            public static let xl: CGFloat = 48
        }

        public enum Button {
            public static let minimumTapTarget: CGFloat = 44
        }

        /// Poster *widths*; heights derive from `PosterImage.aspectRatio`.
        public enum Poster {
            public static let thumbnail: CGFloat = 56
            public static let row: CGFloat = 110
            public static let featured: CGFloat = 200
        }
    }
}
