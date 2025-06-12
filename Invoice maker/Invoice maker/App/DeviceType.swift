import UIKit

enum DeviceType {
    case iPhone, iPad, mac
}

@propertyWrapper
struct Device {
    static var current: DeviceType {
        #if targetEnvironment(macCatalyst)
        return .mac
        #else
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return .iPhone
        case .pad:
            return .iPad
        default:
            return .iPhone
        }
        #endif
    }

    var wrappedValue: DeviceType {
        Self.current
    }
}
