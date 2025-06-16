import SwiftUI

struct ItemCell: ButtonStyle {
    var itemName: String
    var discountType: DiscountType
    var discont: String
    var tax: String
    var total: String
    var currency: Currency
    var editAction: () -> Void
    var deleteAction: () -> Void

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(itemName)
                    .font(.sans(style: .semiBold, size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                
                HStack(spacing: 0) {
                    Text("\(discountText()) \(taxText())")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(configuration.isPressed ? .black767676.opacity(0.5) : .black767676)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                    
                    Text(currency.rawValue + " " + total)
                        .font(.sans(style: .semiBold, size: 12))
                        .foregroundStyle(configuration.isPressed ? .black.opacity(0.5) : .black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
            }

            Spacer()

            HStack(spacing: 4) {
                Button(action: editAction) {
                    Image(.property1Edit)
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.black)
                }
                .frame(width: 40, height: 40)

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
        .frame(maxWidth: .infinity, minHeight: 72, maxHeight: 72)
        .padding(.horizontal, 16)
        .background(.grayF5F5F5)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
    
    private func discountText() -> String {
        "Dis: \(discont.isEmpty ? "0" : discont)\(discountType != .flatAmount ? "%" : " \(currency.rawValue)"),"
    }
    
    private func taxText() -> String {
        "Tax: \(tax.isEmpty ? "0" : tax)% - "
    }
}

extension ButtonStyle where Self == ItemCell {
    static func itemCell(
        itemName: String,
        discountType: DiscountType,
        discont: String,
        tax: String,
        total: String,
        currency: Currency,
        editAction: @escaping () -> Void,
        deleteAction: @escaping () -> Void
    ) -> Self {
        ItemCell(
            itemName: itemName,
            discountType: discountType,
            discont: discont,
            tax: tax,
            total: total,
            currency: currency,
            editAction: editAction,
            deleteAction: deleteAction
        )
    }
}

#Preview {
    Button("") { print("tapOnItemCell") }
        .buttonStyle(
            .itemCell(
                itemName: "Name of item",
                discountType: .percentage,
                discont: "20",
                tax: "20",
                total: "20 000,00",
                currency: .USD,
                editAction: { print("editAction") },
                deleteAction: { print("deleteAction") }
            )
        )
        .padding(16)
}
