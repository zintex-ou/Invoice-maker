import SwiftUI

struct СleanWhiteTemplateFirstPageView: View {
    let templateModel: InvoiceTemplateModel
    @Binding var customColor: Color
    let isWithSummary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Due Date:")
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black767676)
                    
                    Text(templateModel.header.invoiceInfo.dueDate)
                        .font(.sans(style: .regular, size: 12))
                        .foregroundStyle(.black)
                }
                .padding(.top, 28)
                
                Spacer()
                
                InvoiceTopLabel()
            }
            .padding(.bottom, 28)
            
            InvoiceHeaderView(model: templateModel.header, titleColor: .black, type: .cleanWhite)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(customColor)
            
            VStack(spacing: 0) {
                InvoiceTableHeaderView(customColor: customColor)
                
                InvoiceTableRowsView(items: templateModel.items, startIndex: 0, customColor: $customColor)
            }
            
            Spacer()
            
            if isWithSummary {
                ImageSummaryView(headerModel: templateModel.header, summaryModel: templateModel.summary, customColor: customColor, isWithItems: templateModel.items.isEmpty)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 30)
        .padding(.bottom, 60)
        .ignoresSafeArea()
    }
}
