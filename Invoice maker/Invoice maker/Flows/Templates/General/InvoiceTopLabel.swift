import SwiftUI

struct InvoiceTopLabel: View {
    var backgroundSize: CGSize = CGSize(width: 187, height: 101)
    var lineSize: CGSize = CGSize(width: 25, height: 1)
    
    var body: some View {
        ZStack {
            Color.black
                .frame(width: backgroundSize.width, height: backgroundSize.height)
            
            VStack(spacing: 8) {
                Text("INVOICE")
                    .font(.sans(style: .semiBold, size: 26))
                    .foregroundStyle(.white)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: lineSize.width, height: lineSize.height)
            }
        }
        .ignoresSafeArea()
    }
}
