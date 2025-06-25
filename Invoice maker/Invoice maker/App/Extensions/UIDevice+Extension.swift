import UIKit
extension UIDevice {
  var hasHomeButton: Bool {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { ($0 as? UIWindowScene)?.keyWindow }
      .first
    let bottomInset = keyWindow?.safeAreaInsets.bottom ?? 0
    return bottomInset == 0
  }
}
