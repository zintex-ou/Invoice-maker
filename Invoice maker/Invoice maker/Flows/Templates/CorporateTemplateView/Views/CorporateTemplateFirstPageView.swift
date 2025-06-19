import SwiftUI

struct CorporateTemplateFirstPageView: View {
    let templateModel: InvoiceTemplateModel
    @Binding var customColor: Color
    let isWithSummary: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                
                InvoiceTopLabel()
                
                Spacer()
            }
            .padding(.bottom, 40)
            
            InvoiceHeaderView(model: templateModel.header, titleColor: .black, type: .cleanWhite)
                .padding(.bottom, 16)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(customColor)
                .padding(.bottom, 20)
            
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
