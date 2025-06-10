import SwiftUI

struct MainButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.sans(style: .semiBold, size: 16))
            .foregroundStyle(configuration.isPressed ? .white.opacity(0.5) : .white)
            .frame(maxWidth: .infinity, maxHeight: 48)
            .background(.violet4663FF)
            .clipShape(Capsule())
            .minimumScaleFactor(0.8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == MainButton {
    static var main: Self {
        MainButton()
    }
}

#Preview {
    Button("Create invoice") {}
        .buttonStyle(.main)
        .padding(16)
}
