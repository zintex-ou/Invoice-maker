import SwiftUI

extension LinearGradient {
    static let tabBarStroke: LinearGradient = {
        let gradient = Gradient(stops: [
            .init(color: .grayF5F5F5, location: 0),
            .init(color: .white, location: 0.4)
        ])

        return LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom)
    }()
}
