import Foundation

extension Date {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "d MMM, yyyy"
        return f
    }()

    var formatedDateString: String {
        Date.dateFormatter.string(from: self)
    }
}
