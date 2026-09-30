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

        /// Column widths for long-form content.
        public enum Content {
            /// Caps a text column on wide screens such as iPad, where full-width
            /// body text runs past 150 characters a line.
            public static let readableWidth: CGFloat = 680
        }

        /// Block heights for skeleton placeholders.
        public enum Skeleton {
            public static let header: CGFloat = 22
            public static let line: CGFloat = 14
        }
    }
}
