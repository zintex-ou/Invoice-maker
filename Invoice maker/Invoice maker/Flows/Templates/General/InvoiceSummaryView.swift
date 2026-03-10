import SwiftUI

struct InvoiceSummaryView: View {
    var model: InvoiceSummaryModel
    
    private var trimmedFreeField: String {
        model.freeField.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var body: some View {
        VStack {
            divider
            
            SummaryRow(label: "Subtotal", value: "\(model.currency) \(model.subtotal)", isBold: false, color: .black, fontSize: 8)
            
            SummaryRow(label: "Discount:", value: "\(model.discountPercentage)%", isBold: false, color: .black767676, fontSize: 8)
            
            SummaryRow(label: "Tax", value: "\(model.taxPercentage)%", isBold: false, color: .black767676, fontSize: 8)
            
            divider
            
            SummaryRow(label: "TOTAL", value: "\(model.currency) \(model.total)", isBold: true, color: .black, fontSize: 12)
            
            if !trimmedFreeField.isEmpty {
                divider
                    .padding(.top, 6)
                SummaryTextRow(label: "Additional details", value: trimmedFreeField)
            }
        }
    }
    
    private var divider: some View {
        Rectangle()
            .fill(.black.opacity(0.3))
            .frame(height: 1)
    }
}

private struct SummaryTextRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.sans(style: .regular, size: 8))
                .foregroundStyle(.black767676)
            
            Text(value)
                .font(.sans(style: .regular, size: 8))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 6)
    }
}

//#Preview {
//    InvoiceSummaryView(model: .init(currency: .AUD, subtotal: 34.32))
//}

private struct SummaryRow: View {
    let label: String
    let value: String
    let isBold: Bool
    let color: Color
    let fontSize: CGFloat

    var body: some View {
        HStack {
            Text(label)
                .font(.sans(style: .regular, size: fontSize))
                .foregroundStyle(color)
            
            Spacer()
            
            Text(value)
                .font(.sans(style: isBold ? .bold : .regular, size: fontSize))
                .foregroundStyle(color)
        }
    }
}
