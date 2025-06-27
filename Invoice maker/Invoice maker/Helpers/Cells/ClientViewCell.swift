import SwiftUI

struct ClientViewCell: View {
    @EnvironmentObject private var coordinator: Coordinator

    private let client: ClientEntity
    private let isSelectedCell: Bool
    private let deleteAction: (() -> Void)?
    private let viewType: ClientViewType
    
    init(
        client: ClientEntity,
        isSelectedCell: Bool,
        viewType: ClientViewType,
        deleteAction: (() -> Void)? = nil
    ) {
        self.client = client
        self.isSelectedCell = isSelectedCell
        self.viewType = viewType
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(client.clientName ?? "No name")
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                
                Text(client.email ?? "No e-mail")
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(.black767676)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if viewType == .editClient {
                HStack(spacing: 4) {
                    Button {
                        coordinator.pushTo(id: AddNewClientView.navigationID,
                                           destination: { AddNewClientView(viewModel: .init(viewState: .editing(client: client)))
                        })
                    } label: {
                        Image(.property1Edit)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 40, height: 40)
                    
                    Button {
                        deleteAction?()
                    } label: {
                        Image(.property1Trash)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.black)
                    }
                    .frame(width: 40, height: 40)
                }
            } else {
                if isSelectedCell {
                    Image(.property1Tick)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.violet4663FF)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 32))
    }
}
