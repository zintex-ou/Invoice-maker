import SwiftUI

struct PopupButtonStyle: ButtonStyle {
    var isChosen: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            configuration.label
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(isChosen ? .violet4663FF : .black)

            Spacer()

            if isChosen {
                Image(.checkMarkIcon)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
        }
        .opacity(configuration.isPressed ? 0.5 : 1)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .padding(.horizontal, 16)
        .frame(height: 44)
        .contentShape(Rectangle())
    }
}

extension ButtonStyle where Self == PopupButtonStyle {
    static func popupButton(isChosen: Bool) -> Self {
        PopupButtonStyle(isChosen: isChosen)
    }
}

#Preview {
    VStack {
        Button("Paid") {}
            .buttonStyle(.popupButton(isChosen: true))

        Button("Unpaid") {}
            .buttonStyle(.popupButton(isChosen: false))

        Button("None") {}
            .buttonStyle(.popupButton(isChosen: true))

        Button("Percentage") {}
            .buttonStyle(.popupButton(isChosen: false))

        Button("Flat amount") {}
            .buttonStyle(.popupButton(isChosen: false))
    }
    .frame(width: 176)
}
