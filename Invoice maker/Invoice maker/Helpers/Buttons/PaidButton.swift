import SwiftUI

struct PaidButton: ButtonStyle {
    @Binding var isPaid: Bool
    var isPopoverShown: Bool
    let namespace: Namespace.ID
    let id: Int

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 2) {
            configuration.label
                .font(.sans(style: .regular, size: 12))
                .foregroundColor(configuration.isPressed ? .black.opacity(0.5) : .black)
                .minimumScaleFactor(0.8)
                .transition(.scale)

            Image(.menuOffIcon)
                .resizable()
                .renderingMode(.template)
                .frame(width: 12, height: 12)
                .foregroundStyle(.black)
                .rotation3DEffect(
                    .degrees(isPopoverShown ? 180 : 0),
                    axis: (x: 1, y: 0, z: 0)
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .foregroundStyle(isPaid ? .greenB4F5C4 : .blueDAE0FF)
                .transition(.scale)
        )
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
        .matchedGeometryEffect(id: id, in: namespace, anchor: .init(x: 1, y: 1))
    }
}

extension ButtonStyle where Self == PaidButton {
    static func paid(
        isPaid: Binding<Bool>,
        isPopoverShown: Bool,
        namespace: Namespace.ID,
        id: Int = 1
    ) -> Self {
        PaidButton(
            isPaid: isPaid,
            isPopoverShown: isPopoverShown,
            namespace: namespace,
            id: id
        )
    }
}

#Preview {
    VStack {
        Button("Paid") {}
            .buttonStyle(
                PaidButton(
                    isPaid: .constant(true),
                    isPopoverShown: false,
                    namespace: Namespace().wrappedValue,
                    id: 1
                )
            )

        Button("Unpaid") {}
            .buttonStyle(
                PaidButton(
                    isPaid: .constant(false),
                    isPopoverShown: false,
                    namespace: Namespace().wrappedValue,
                    id: 1
                )
            )
    }
}
