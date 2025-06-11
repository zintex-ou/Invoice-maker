import SwiftUI

@main
struct Invoice_makerApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            CoordinatorView()
        }
    }
}
