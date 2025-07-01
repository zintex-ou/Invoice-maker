import SafariServices
import UIKit
import SwiftUI

extension UIApplication {
    var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "Invoice Maker"
    }

    func openPrivacy() {
        guard let url = URL(string: AppConstants.getValue(.privacyUrl)) else { return }
        openSafariWebController(for: url)
    }

    func openTerms() {
        guard let url = URL(string: AppConstants.getValue(.termsUrl)) else { return }
        openSafariWebController(for: url)
    }

    func shareApp() {
        let textToShare: [Any] = [AppConstants.getValue(.appUrl)]

        let activityViewController = UIActivityViewController(
            activityItems: textToShare,
            applicationActivities: nil
        )

        if UIDevice.current.userInterfaceIdiom == .pad {
            guard let sourceView = topViewController?.view else { return }
            activityViewController.popoverPresentationController?.sourceView = sourceView
            activityViewController.popoverPresentationController?.sourceRect = CGRect(
                x: sourceView.bounds.midX,
                y: sourceView.bounds.midY,
                width: 0,
                height: 0
            )
            activityViewController.popoverPresentationController?.permittedArrowDirections = []
        }

        topViewController?.present(activityViewController, animated: true)
    }

    var topViewController: UIViewController? {
        var topViewController = connectedScenes.compactMap {
            ($0 as? UIWindowScene)?.windows
                .filter { $0.isKeyWindow }
                .first?
                .rootViewController
        }
        .first

        if let presented = topViewController?.presentedViewController {
            topViewController = presented
        } else if let navController = topViewController as? UINavigationController {
            topViewController = navController.topViewController
        } else if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        return topViewController
    }
}

private extension UIApplication {
    func openSafariWebController(for url: URL) {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let vc = SFSafariViewController(url: url, configuration: config)
        topViewController?.present(vc, animated: true)
    }
}

extension UIApplication {
    private static var overlayWindow: UIWindow?

    func presentOverlay<Content: View>(@ViewBuilder content: () -> Content) {
        guard Self.overlayWindow == nil else { return }

        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .clear

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = hostingController
            window.windowLevel = .alert + 1
            window.makeKeyAndVisible()
            Self.overlayWindow = window
        }
    }
    
    func dismissOverlay() {
        Self.overlayWindow?.isHidden = true
        Self.overlayWindow = nil
    }
}
