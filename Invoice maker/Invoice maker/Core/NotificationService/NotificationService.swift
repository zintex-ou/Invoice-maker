import Foundation

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func post(event: NotificationEvent, object: Any?) {
        NotificationCenter.default.post(
            name: NSNotification.Name(event.rawValue),
            object: object
        )
    }
    
    func observe(event: NotificationEvent, handler: @escaping (Any?) -> Void) {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name(event.rawValue),
            object: nil,
            queue: .main
        ) { notification in
            let object = notification.object
            handler(object)
        }
    }
    
    func remove(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
}
