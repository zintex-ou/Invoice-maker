import SwiftUI
import Foundation

extension AngularGradient {
    static var greenGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: Color(red: 0.3, green: 0.85, blue: 0.39), location: 0.00),
                .init(color: Color(red: 0.61, green: 1.00, blue: 0.67), location: 0.62),
                .init(color: Color(red: 0.24, green: 0.80, blue: 0.34), location: 1.00),
            ],
            center: UnitPoint(x: 1, y: 0.1)
        )
    }

    static var blueGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: Color(red: 0.27, green: 0.39, blue: 1.00), location: 0.00),
                .init(color: Color(red: 0.62, green: 0.86, blue: 0.98), location: 0.62),
                .init(color: Color(red: 0.73, green: 0.80, blue: 0.98), location: 1.00),
            ],
            center: UnitPoint(x: 1, y: 0.1)
        )
    }
}
