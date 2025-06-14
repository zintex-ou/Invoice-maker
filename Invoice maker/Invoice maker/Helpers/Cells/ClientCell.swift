import SwiftUI

struct ClientCell: ButtonStyle {
    var clientName: String
    var clientEmail: String
    var editAction: (() -> Void)?
    var deleteAction: (() -> Void)?

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(clientName)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)

                Text(clientEmail)
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(configuration.isPressed ? .black767676.opacity(0.5) : .black767676)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                if let editAction = editAction {
                    Button(action: editAction) {
                        Image(.property1Edit)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 40, height: 40)
                }

                if let deleteAction = deleteAction {
                    Button(action: deleteAction) {
                        Image(.property1Trash)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 40, height: 40)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension ButtonStyle where Self == ClientCell {
    static func clientCellWithActions(
        clientName: String,
        clientEmail: String,
        editAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void
    ) -> Self {
        ClientCell(
            clientName: clientName,
            clientEmail: clientEmail,
            editAction: editAction,
            deleteAction: deleteAction
        )
    }

    static func clientCell(
        clientName: String,
        clientEmail: String
    ) -> Self {
        ClientCell(
            clientName: clientName,
            clientEmail: clientEmail
        )
    }
}

#Preview {
    VStack {
        Button("") {}
            .buttonStyle(
                .clientCellWithActions(
                    clientName: "Name",
                    clientEmail: "user_name@gmail.com",
                    editAction: { print("editAction") },
                    deleteAction: { print("deleteAction") }
                )
            )

        Button("") {}
            .buttonStyle(
                .clientCell(
                    clientName: "Name",
                    clientEmail: "user_name@gmail.com"
                )
            )
    }
    .padding(16)
}
