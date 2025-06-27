import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = InvoicesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                SegmentedControl(
                    selection: $viewModel.invoiceSelection,
                    segments: SegmentInvoiceType.allCases
                )
                .padding(.top, 24)
                .padding(.bottom, 4)
                
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
            
            HStack {
                Button("Create Invoice") {
                    coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                        CreateInvoiceView(viewModel: .init(viewType: .createInvoice))
                    }
                }
                .buttonStyle(.main)
            }
            .padding(.vertical, 8)
            .background(.white)
        }
        .padding(.horizontal, 16)
        .animation(.default, value: viewModel.allInvoices.count)
        .animation(.default, value: viewModel.paidInvoices.count)
        .animation(.default, value: viewModel.unPaidInvoices.count)
    }
    
    private var invoiceList: some View {
        ZStack(alignment: .top) {
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
                            
                            Button {
                                coordinator.pushTo(id: PreviewView.navigationID, destination: {
                                    PreviewView(viewModel: .init(invoiceEntity: invoice, isWithStatusChange: true))
                                })
                            } label: {
                                InvoiceViewCell(
                                    nameOfClient: name,
                                    dueDate: dueDate,
                                    currency: Currency(from: invoice.currency),
                                    totalPrice: total,
                                    isInvoice: invoice.isInvoice,
                                    isPaid: isPaid) { isPaid in
                                        viewModel.change(isPaid: isPaid, for: id)
                                    }
                            }
                        }
                    }
                }
                .padding(.top, 24)
            }
            .scrollIndicators(.hidden)
            
            ListTopShadow()
        }
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
