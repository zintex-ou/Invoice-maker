import UIKit

extension UIApplication {
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Invoice Maker"
    }
}
