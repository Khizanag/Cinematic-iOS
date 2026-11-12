import CinematicDesign
import SwiftUI

/// The shared xmark dismiss item for sheets and covers.
struct CloseToolbarItem: ToolbarContent {
    let action: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(action: action) {
                Image(systemName: "xmark")
            }
            .tint(DesignSystem.Color.chrome)
            .accessibilityLabel(Text("general.close"))
        }
    }
}
