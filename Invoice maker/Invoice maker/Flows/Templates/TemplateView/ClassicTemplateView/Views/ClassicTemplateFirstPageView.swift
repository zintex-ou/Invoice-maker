import SwiftUI

struct ClassicTemplateFirstPageView: View {
    let templateModel: InvoiceTemplateModel
    @Binding var customColor: Color
    let isWithSummary: Bool
    
    var body: some View {
        VStack {
            ZStack {
                customColor
                    .ignoresSafeArea()
                
                HStack {
                    if let logo = templateModel.header.logo,
                       let image = UIImage(data: logo) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 72, height: 72)
                            .padding(.trailing, 59)
                    } else {
                        Image(uiImage: .logo)
                            .resizable()
                            .frame(width: 72, height: 72)
                            .padding(.trailing, 59)
                    }
                    
                    InvoiceHeaderView(model: templateModel.header, titleColor: .black, type: .classic)
                }
                .padding(.horizontal, 30)
            }
            .frame(height: 181)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("INVOICE")
                    .font(.sans(style: .semiBold, size: 26))
                
                Rectangle()
                    .frame(width: 26, height: 1)
                    .foregroundColor(.black)
                
                VStack(spacing: 0) {
                    InvoiceTableHeaderView(customColor: customColor)
                    
                    InvoiceTableRowsView(items: templateModel.items, startIndex: 0, customColor: $customColor)
                }
                
                Spacer()
                
                if isWithSummary {
                    TextSummaryView(
                        headerModel: templateModel.header,
                        summaryModel: templateModel.summary,
                        customColor: customColor,
                        isWithItems: templateModel.items.isEmpty
                    )
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 30)
            .padding(.bottom, 60)
            .padding(.top, 40)
            .ignoresSafeArea()
        }
    }
}
