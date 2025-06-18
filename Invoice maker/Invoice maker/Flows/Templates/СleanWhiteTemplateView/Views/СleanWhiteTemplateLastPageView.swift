import SwiftUI

struct СleanWhiteTemplateLastPageView: View {
    let templateModel: InvoiceTemplateModel
    @Binding var customColor: Color
    
    let startIndex: Int

    var body: some View {
        VStack(spacing: 0) {
            if !templateModel.items.isEmpty {
                InvoiceTableHeaderView(customColor: customColor)
            }
            
            InvoiceTableRowsView(items: templateModel.items, startIndex: startIndex, customColor: $customColor)
            
            ImageSummaryView(headerModel: templateModel.header, summaryModel: templateModel.summary, customColor: customColor, isWithItems: templateModel.items.isEmpty)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 30)
        .padding(.bottom, 60)
        .padding(.top, 40)
        .ignoresSafeArea()
    }
}
