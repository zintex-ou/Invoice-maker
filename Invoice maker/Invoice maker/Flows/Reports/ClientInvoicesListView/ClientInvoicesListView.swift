import SwiftUI

struct ClientInvoicesListView: View {
    @StateObject var viewModel: ClientInvoicesListViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @Namespace private var namespace
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                navigationBar
                    .padding(.bottom, 24)
                
                SegmentedControl(
                    selection: $viewModel.invoiceSelection,
                    segments: SegmentInvoiceType.allCases
                )
                .padding(.bottom, 16)
       
#warning("Refactor")
                VStack(spacing: 8) {
                    ForEach(viewModel.filteredDetailViewModels) { model in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.grayF5F5F5)
                            
                            InvoiceDetailsView(
                                clientName: model.invoiceNumber,
                                dueDate: model.dueDate,
                                currency: model.currency,
                                total: model.total,
                                namespace: namespace,
                                isPaid: model.isPaid,
                                isPopoverShown: model.isPresented
                            )
                            .padding(16)
                        }
                        .zIndex(100)
                        .overlay(alignment: .topTrailing) {
                            VStack { }
                            .paidPopover(
                                isPaid: model.isPaid,
                                isPresented: model.isPresented,
                                selectedID: .constant(1),
                                namespace: namespace
                            ) {
                                viewModel.updateStatus()
                            }
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
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
                
                Text(viewModel.report.name)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}
