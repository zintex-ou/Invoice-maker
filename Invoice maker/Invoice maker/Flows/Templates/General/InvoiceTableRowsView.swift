import SwiftUI

struct InvoiceTableRowsView: View {
    let items: [InvoiceItemRowModel]
    let startIndex: Int
    @Binding var customColor: Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                cellRow(item: item, index: index)
            }
        }
    }
    
    private func cellRow(item: InvoiceItemRowModel, index: Int ) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                cell(text: item.name, width: 80, alignment: .leading)
                
                cell(text: "\(item.pricePerUnit)", width: 113, alignment: .leading)
                
                cell(text: "\(item.quantity)", width: 70, alignment: .leading)
                
                cell(text: "\(item.discountPercentage)", width: 70, alignment: .leading)
                
                cell(text: "\(item.taxPercentage)", width: 50, alignment: .leading)
                
                cell(text: "\(item.total)", width: 113, alignment: .trailing)
            }
            .padding(11)
            
            Rectangle()
                .fill(customColor)
                .frame(height: 1)
        }
        .frame(height: 32)
    }

    private func cell(text: String, width: CGFloat, alignment: Alignment) -> some View {
        Text(text)
            .font(.sans(style: .regular, size: 8))
            .foregroundColor(.black)
            .frame(width: width, alignment: alignment)
            .lineLimit(1)
    }
}
