import SwiftUI

struct ClassicTemplateContinuationView: View {
    let items: [InvoiceItemRowModel]
    let startIndex: Int
    @Binding var customColor: Color

    var body: some View {
        VStack(spacing: 0) {
            InvoiceTableHeaderView(customColor: customColor)
            
            InvoiceTableRowsView(items: items, startIndex: startIndex, customColor: $customColor)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 30)
        .padding(.bottom, 60)
        .padding(.top, 40)
        .ignoresSafeArea()
    }
}
