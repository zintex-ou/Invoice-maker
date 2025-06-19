import SwiftUI

struct TextSummaryView: View {
    let headerModel: InvoiceHeaderModel
    let summaryModel: InvoiceSummaryModel
    var customColor: Color
    var isWithItems: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 96) {
            VStack(alignment: .leading) {
                Text("Due Date:")
                    .font(.sans(style: .semiBold, size: 12))
                    .foregroundStyle(.black)
                
                Text(headerModel.invoiceInfo.dueDate)
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(.black767676)
            }
            
            InvoiceSummaryView(model: summaryModel)
                .padding(10)
                .background(customColor)
        }
        .padding(.top, isWithItems ? 0 : 100)
    }
}
