import SwiftUI

struct ClientInvoicesListView: View {
    @StateObject var viewModel: ClientInvoicesListViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @Namespace private var namespace
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 24)
            
            SegmentedControl(
                selection: $viewModel.invoiceSelection,
                segments: SegmentInvoiceType.allCases
            )
            .padding(.bottom, 4)
            
            if viewModel.getInvoices().isEmpty {
                emptyStateView
            } else {
                invoicesList
            }
        }
        .padding(.horizontal, 16)
        .animation(.default, value: viewModel.allInvoices.count)
        .animation(.default, value: viewModel.paidInvoices.count)
        .animation(.default, value: viewModel.unpaidInvoices.count)
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.popToBack()
                }
                .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text(viewModel.title)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
    
    private var invoicesList: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.getInvoices(), id: \.id) { invoice in
                        if let id = invoice.id,
                           let name = invoice.client?.clientName,
                           let dueDate = invoice.invoiceDate {
                            
                            let isPaidBinding = Binding<Bool>(
                                get: { invoice.isPaid },
                                set: { newValue in
                                    viewModel.change(isPaid: newValue, for: id)
                                }
                            )
                            
                            InvoiceViewCell(
                                title: name,
                                dueDate: dueDate,
                                currency: Currency(from: invoice.currency),
                                totalPrice: invoice.total,
                                isInvoice: invoice.isInvoice,
                                isPaid: isPaidBinding
                            )
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
