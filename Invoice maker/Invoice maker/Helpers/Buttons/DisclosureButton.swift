import SwiftUI

struct DisclosureButton: ButtonStyle {
    let title: String
    let isRequired: Bool

    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 1) {
                Text(title)
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(.black767676)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.leading, 16)

                if isRequired {
                    Text("*")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.violet4663FF)
                }
            }

            HStack(spacing: 0) {
                configuration.label
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                Image(.pushIcon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
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

extension ButtonStyle where Self == DisclosureButton {
    static func disclosure(title: String, isRequired: Bool = false) -> Self {
        DisclosureButton(title: title, isRequired: isRequired)
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("USD") { print("Disclosure action") }
            .buttonStyle(.disclosure(title: "Currency"))

        Button("Business profile") { print("Disclosure action") }
            .buttonStyle(.disclosure(title: "From", isRequired: true))

        HStack(spacing: 12) {
            Button("2 May, 2025") { print("Disclosure action") }
                .buttonStyle(.disclosure(title: "Invoice date"))

            Button("2 May, 2025") { print("Disclosure action") }
                .buttonStyle(.disclosure(title: "Due date"))
        }
    }
    .padding(16)
}
