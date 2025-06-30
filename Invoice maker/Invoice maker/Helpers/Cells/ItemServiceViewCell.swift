import SwiftUI

struct ItemServiceViewCell: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    private let itemService: ItemServiceEntity
    private let isSelectedCell: Bool
    private let deleteAction: (() -> Void)?
    private let offerSelection: SegmentOfferType
    private let viewType: ItemServiceViewType
    
    init(
        itemService: ItemServiceEntity,
        isSelectedCell: Bool = false,
        offerSelection: SegmentOfferType,
        viewType: ItemServiceViewType,
        deleteAction: (() -> Void)? = nil,
    ) {
        self.itemService = itemService
        self.isSelectedCell = isSelectedCell
        self.offerSelection = offerSelection
        self.viewType = viewType
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(itemService.name ?? "No name")
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(.black)
                
                HStack(spacing: 0) {
                    let currency = itemService.currency ?? "USD"
                    let totalPrice = itemService.total ?? "0.0"
                    
                    Text("\(discountText()), \(taxText())")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black767676)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(currency + " " + totalPrice)
                        .font(.sans(style: .semiBold, size: 12))
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if viewType == .editItemsOrServices {
                HStack(spacing: 4) {
                    Button {
                        coordinator.pushTo(
                            id: AddNewItemServiceView.navigationID,
                            destination: {
                                AddNewItemServiceView(
                                    viewModel: .init(
                                        offerType: offerSelection,
                                        viewState: .editing(entity: itemService)
                                    )
                                )
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
    
    private func discountText() -> String {
        let discont = itemService.discount ?? "0"
        let currency = itemService.currency ?? "USD"
        let discountType = DiscountType(from: itemService.discountType)
        return "Dis: \(discont)\(discountType != .flatAmount ? "%" : " \(currency)")"
    }
    
    private func taxText() -> String {
        let tax = itemService.tax ?? ")"
        return "Tax: \(tax)% - "
    }
}
