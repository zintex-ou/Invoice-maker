import SwiftUI

struct MinimalTemplateFirstPageView: View {
    let templateModel: InvoiceTemplateModel
    @Binding var customColor: Color
    let isWithSummary: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                ZStack {
                    Rectangle()
                        .fill(customColor)
                        .frame(height: 37)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(height: 37)
                        .padding(.leading, 30)
                        .padding(.trailing, 101)
                }
                .padding(.top, 44)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text("INVOICE")
                            .font(.sans(style: .semiBold, size: 26))
                            .foregroundStyle(.black)
                            .padding(.top, 8)
                        
                        Text(templateModel.header.businessProfile.name)
                            .font(.sans(style: .semiBold, size: 16))
                            .foregroundStyle(.black)
                        
                        Text("Due Date:")
                            .font(.sans(style: .regular, size: 12))
                            .foregroundStyle(.black767676)
                        
                        Text(templateModel.header.invoiceInfo.dueDate)
                            .font(.sans(style: .regular, size: 12))
                            .foregroundStyle(.black)
                    }
                    
                    Spacer()
                    
                    if let logo = templateModel.header.logo,
                       let image = UIImage(data: logo) {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 72, height: 72)
                            //  .padding(.trailing, 59)
                    } else {
                        Image(uiImage: .logo)
                            .resizable()
                            .frame(width: 72, height: 72)
                         //   .padding(.trailing, 59)
                    }
                }
                .padding(.top, 40)
                .padding(.leading, 42)
                .padding(.trailing, 125)
            }
            .padding(.bottom, 48)
            
            VStack(alignment: .leading, spacing: 0) {
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
            .padding(.horizontal, 42)
        }
        .padding(.bottom, 60)
        .ignoresSafeArea()
    }
}
