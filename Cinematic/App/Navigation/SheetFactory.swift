import SwiftUI

/// Maps a `Sheet` to its content. Sheets get their own `NavigationStack`,
/// so the host stack stays on the screen underneath.
struct SheetFactory: View {
    let sheet: Sheet

    var body: some View {
        switch sheet {
        case .about:
            NavigationStack {
                AboutView()
            }
        }
    }
}
