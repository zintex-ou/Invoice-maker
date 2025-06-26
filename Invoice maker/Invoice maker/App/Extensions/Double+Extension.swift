import SwiftUI

extension Double {
    var formattedWithoutDecimals: String {
        let intValue = Int(self)
        if intValue != 0, intValue % 1000 == 0 {
            return "\(intValue / 1000)k"
        } else {
            return "\(intValue)"
        }
    }
}
