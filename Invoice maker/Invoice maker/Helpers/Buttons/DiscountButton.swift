import SwiftUI

struct DiscountButton: ButtonStyle {
    var isPopoverShown: Bool

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 1) {
                Text("Discount")
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(.black767676)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.leading, 16)
            }

            HStack(spacing: 0) {
                configuration.label
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                    .lineLimit(1)

                Spacer()

                Image(.discountArrow)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.black)
                    .rotation3DEffect(
                        .degrees(isPopoverShown ? 180 : 0),
                        axis: (x: 1, y: 0, z: 0)
                    )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                Capsule()
                    .foregroundStyle(.grayF5F5F5)
            }
            .contentShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        }
    }
}

extension ButtonStyle where Self == DiscountButton {
    static func discount(isPopoverShown: Bool) -> Self {
        DiscountButton(isPopoverShown: isPopoverShown)
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("None") { print("Discount action") }
            .buttonStyle(.discount(isPopoverShown: true))

        Button("Percentage") { print("Discount action") }
            .buttonStyle(.discount(isPopoverShown: false))

        Button("Flat amount") { print("Discount action") }
            .buttonStyle(.discount(isPopoverShown: false))
    }
    .padding(16)
}
