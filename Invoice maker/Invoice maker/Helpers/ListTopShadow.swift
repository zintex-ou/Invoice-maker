import SwiftUI

struct ListTopShadow: View {
    var shadowHeight: CGFloat?

    var body: some View {
        Rectangle()
            .frame(height: shadowHeight ?? 14)
            .foregroundStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .white, location: 0.1),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
}
