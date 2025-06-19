import SwiftUI

struct ImageSummaryView: View {
    let headerModel: InvoiceHeaderModel
    let summaryModel: InvoiceSummaryModel
    var customColor: Color
    var isWithItems: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 96) {
            if let logo = headerModel.logo,
               let image = UIImage(data: logo) {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 72, height: 72)
            } else {
                Image(uiImage: .logo)
                    .resizable()
                    .frame(width: 72, height: 72)
            }
            
            InvoiceSummaryView(model: summaryModel)
                .padding(10)
                .background(customColor)
        }
        .padding(.top, isWithItems ? 0 : 100)
    }
}
