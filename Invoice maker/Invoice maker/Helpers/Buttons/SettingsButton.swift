import SwiftUI

struct SettingsButton: ButtonStyle {
    var icon: ImageResource

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)

            configuration.label
                .font(.sans(style: .semiBold, size: 16))
                .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)

            Spacer()

            Image(.pushIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
        }
        .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(Capsule())
        .minimumScaleFactor(0.8)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == SettingsButton {
    static func settings(_ icon: ImageResource) -> Self {
        SettingsButton(icon: icon)
    }
}

#Preview {
    Button("Business profile") {}
        .buttonStyle(.settings(.property1Profile))
        .padding(16)
}
