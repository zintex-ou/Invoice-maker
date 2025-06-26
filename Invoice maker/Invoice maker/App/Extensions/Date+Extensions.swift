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
    
    func isSameOrAfterDateIgnoringTime(_ otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let selfDate = calendar.startOfDay(for: self)
        let otherDate = calendar.startOfDay(for: otherDate)
        return selfDate >= otherDate
    }
}
