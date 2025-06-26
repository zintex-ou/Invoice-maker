import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = InvoicesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                MainHeader(isPremium: $viewModel.isPremium) {
                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                        PaywallView()
                    }
                }
                .padding(.top, 12)
                
                Spacer()
                
                emptyStateView
                
                Spacer()
            }
            
            Button("Create Invoice") {
                coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                    CreateInvoiceView(viewModel: .init(viewType: .createInvoice))
                }
            }
            .buttonStyle(.main)
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 16)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(.grayF5F5F5)
                .frame(width: 56, height: 56)
                .overlay {
                    Image(.property1Invoices)
                }
            
            VStack(spacing: 4) {
                Text("Invoices")
                    .foregroundStyle(.black)
                    .font(.sans(style: .semiBold, size: 26))
                
                Text("Start by creating an invoice. Look\nprofessional to your clients.")
                    .foregroundStyle(.black767676)
                    .font(.sans(style: .regular, size: 16))
            }
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    InvoicesView()
}
