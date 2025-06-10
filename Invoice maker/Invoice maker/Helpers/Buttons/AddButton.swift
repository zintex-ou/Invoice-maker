import SwiftUI

struct AddButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            Image(.property1Plus)
                .resizable()
                .renderingMode(.template)
                .frame(width: 21, height: 20)
                .foregroundStyle(configuration.isPressed ? .violet4663FF.opacity(0.5) : .violet4663FF)

            configuration.label
                .font(.sans(style: .semiBold, size: 16))
                .foregroundStyle(configuration.isPressed ? .violet4663FF.opacity(0.5) : .violet4663FF)
        }
        .frame(maxWidth: .infinity, maxHeight: 48)
        .background(.white)
        .clipShape(Capsule())
        .minimumScaleFactor(0.8)
        .overlay(
            Capsule()
                .stroke(.violet4663FF, lineWidth: 1)
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == AddButton {
    static var add: Self {
        AddButton()
    }
}

#Preview {
    Button("Add item&service") {}
        .buttonStyle(.add)
        .padding(16)
}
