import UIKit

enum AppConstantKey: String, Decodable {
    case email
    case appUrl
    case termsUrl
    case privacyUrl
    case adaptyKey
    case mailAppUrl
    case isOnboardingCompleted
}

enum AppConstants {
    static func getValue(_ key: AppConstantKey) -> String {
        guard let value = dict[key.rawValue] else {
            fatalError("Missing key \(key.rawValue) in AppConstants.plist")
        }
        return value
    }

    private static var dict: [String: String] = {
        guard let url = Bundle.main.url(forResource: "AppConstants", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let raw = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else {
            fatalError("Failed to load AppConstants.plist")
        }

        return raw.compactMapValues { $0 as? String }
    }()
}
