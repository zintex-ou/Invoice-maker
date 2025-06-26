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
                
                switch viewModel.invoiceSelection {
                case .all:
                    if viewModel.allInvoices.isEmpty {
                        emptyStateView
                    } else {
                        invoiceList
                    }
                case .paid:
                    if viewModel.paidInvoices.isEmpty {
                        emptyStateView
                    } else {
                        invoiceList
                    }
                case .unpaid:
                    if viewModel.unPaidInvoices.isEmpty {
                        emptyStateView
                    } else {
                        invoiceList
                    }
                }
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
        .task {
            await viewModel.fetchInvoices()
        }
    }
    
    private var invoiceList: some View {
        VStack(spacing: .zero) {
            SegmentedControl(
                selection: $viewModel.invoiceSelection,
                segments: SegmentInvoiceType.allCases
            )
            
            var model: [InvoiceEntity] {
                switch viewModel.invoiceSelection {
                case .all:
                    return viewModel.allInvoices
                case .paid:
                    return viewModel.paidInvoices
                case .unpaid:
                    return viewModel.unPaidInvoices
                }
            }
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(model, id: \.id) { invoice in
                        if let id = invoice.id,
                           let name = invoice.client?.clientName,
                           let dueDate = invoice.dueDate {
                            
                            let total = invoice.total
                            let isPaid = invoice.isPaid
                            
                            InvoiceViewCell(
                                nameOfClient: name,
                                dueDate: dueDate,
                                currency: Currency(from: invoice.currency),
                                totalPrice: total,
                                isPaid: isPaid) { isPaid in
                                    viewModel.changeIsPaid(status: isPaid, for: id)
                                }
                        }
                    }
                }
                .padding(.top, 24)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.top, 24)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
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
            
            Spacer()
        }
    }
}

#Preview {
    InvoicesView()
}
