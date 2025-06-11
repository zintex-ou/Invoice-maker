import SwiftUI

struct TabBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(Capsule())
    }
}

extension ButtonStyle where Self == TabBarButtonStyle {
    static var tabBar: Self {
        TabBarButtonStyle()
    }
}
