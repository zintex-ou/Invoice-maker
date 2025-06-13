import SwiftUI

struct RadioButton: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.violet4663FF)
                    .frame(width: 20, height: 20)

                Circle()
                    .foregroundStyle(.violet4663FF)
                    .frame(width: isSelected ? 12 : 0, height: isSelected ? 12 : 0)
                    .transition(.scale)
                    .animation(.default, value: isSelected)
            }

            configuration.label
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14.5)
        .background {
            Capsule()
                .foregroundStyle(.grayF5F5F5)
        }
        .contentShape(Capsule())
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == RadioButton {
    static func radioButton(isSelected: Bool) -> Self {
        RadioButton(isSelected: isSelected)
    }
}

#Preview {
    VStack {
        Button("USD") { print("Choose USD") }
            .buttonStyle(.radioButton(isSelected: true))

        Button("EUR") { print("Choose USD") }
            .buttonStyle(.radioButton(isSelected: false))
    }
}
