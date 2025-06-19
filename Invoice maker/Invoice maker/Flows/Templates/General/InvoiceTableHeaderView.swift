import SwiftUI

struct InvoiceTableHeaderView: View {
    var customColor: Color
    
    var body: some View {
        ZStack {
            customColor
                .frame(height: 32)
            
            HStack(spacing: 0) {
                headerCell("Item&service", 80, isBold: false, alignment: .leading)
                
                headerCell("Price per unit", 113, isBold: false, alignment: .leading)
                
                headerCell("Quantity (hour)", 70, isBold: false, alignment: .leading)
                
                headerCell("Discount", 70, isBold: false, alignment: .leading)
                
                headerCell("Tax", 50, isBold: false, alignment: .leading)
                
                headerCell("Total", 113, isBold: true, alignment: .trailing)
            }
            .padding(12)
        }
    }
    
    private func headerCell(_ text: String, _ width: CGFloat, isBold: Bool, alignment: Alignment) -> some View {
        Text(text)
            .font(.sans(style: isBold ? .bold : .regular, size: 8))
            .foregroundColor(.black)
            .frame(width: width, height: 24, alignment: alignment)
    }
}
