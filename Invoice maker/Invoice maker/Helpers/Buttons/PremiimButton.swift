import SwiftUI

struct PremiumButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Image(.crown)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
            
            configuration.label
                .font(.sans(style: .semiBold, size: 20))
        }
        .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.41, green: 0.92, blue: 0.54, opacity: 0.5), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.63, green: 0.77, blue: 1, opacity: 0.5), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.15, y: 0.16),
                endPoint: UnitPoint(x: 0.78, y: 0.7)
            )
        )
        .clipShape(Capsule())
        .minimumScaleFactor(0.8)
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == PremiumButton {
    static var premium: Self {
        PremiumButton()
    }
}

#Preview {
    Button("Pro".uppercased()) { }
        .buttonStyle(.premium)
}
