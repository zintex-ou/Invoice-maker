import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coreDataManager = CoreDataManager.shared
    private let dataBaseService = InvoiceDataBaseService.shared
    
    var shortcutItem: UIApplicationShortcutItem!
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let shortcut = connectionOptions.shortcutItem else { return }
        shortcutItem = shortcut
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        Task {
            await dataBaseService.fetchInvoices()
        }
        
        guard let shortcutItem else { return }
        handle(shortcutItem: shortcutItem)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        do {
            try coreDataManager.saveContext()
            print("Saved context successfully.")
        } catch let error {
            print("Failed save context, with error: \(error)")
        }
    }
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let handled = handle(shortcutItem: shortcutItem)
        completionHandler(handled)
    }
    
    @discardableResult
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let shortcutType = ShortCutType(rawValue: shortcutItem.type) else { return false }
        
        switch shortcutType {
        case .mail:
            ContactSheet.shared.presentContactSheet()
        }
        return true
    }
}
