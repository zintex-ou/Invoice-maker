import SwiftUI

struct CircleButton: ButtonStyle {
    var icon: ImageResource
    var color: Color
    var title: String?

    init(icon: ImageResource, color: Color = .black, title: String? = nil) {
        self.icon = icon
        self.color = color
        self.title = title
    }

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.grayF5F5F5)

                Image(icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(configuration.isPressed ? color.opacity(0.5) : color)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)

            if let title = title {
                Text(title)
                    .font(.sans(style: .regular, size: 12))
                    .foregroundColor(color)
            }
        }
    }
}

extension ButtonStyle where Self == CircleButton {
    static func circle(_ icon: ImageResource, title: String? = nil) -> Self {
        CircleButton(icon: icon, title: title)
    }

    static func distructiveCircle(_ icon: ImageResource, title: String? = nil) -> Self {
        CircleButton(icon: icon, color: .redDF0101, title: title)
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("") {}
            .buttonStyle(.circle(.property1Arrow))

        Button("") {}
            .buttonStyle(.distructiveCircle(.property1Trash))

        Button("") {}
            .buttonStyle(.circle(.property1Share, title: "Share"))

        Button("") {}
            .buttonStyle(.distructiveCircle(.property1Trash, title: "Delete"))
    }
    .padding(16)
}
