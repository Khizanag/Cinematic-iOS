import SwiftUI

/// Whether the app launched under the UI-test harness (`-uiTestMode`).
///
/// One source of truth for the launch flag: the composition root reads it to
/// inject in-memory dependencies, and the root view reads it to calm
/// animations so XCUITest settles immediately.
enum UITestSupport {
    static var isActive: Bool {
        #if DEBUG
        ProcessInfo.processInfo.arguments.contains("-uiTestMode")
        #else
        false
        #endif
    }
}

// MARK: - Calm UI under test
extension View {
    /// Under `-uiTestMode`, disables implicit and navigation animations so the
    /// UI reaches an idle state at once — XCUITest waits on idleness, and the
    /// cold first launch is flaky while transitions are still running. No
    /// effect in normal runs.
    @ViewBuilder
    func calmForUITests() -> some View {
        if UITestSupport.isActive {
            transaction { $0.animation = nil }
        } else {
            self
        }
    }
}
