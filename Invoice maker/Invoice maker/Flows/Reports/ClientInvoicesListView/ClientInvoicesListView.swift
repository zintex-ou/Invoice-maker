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
                
                VStack(spacing: 8) {
                    ForEach(viewModel.filteredDetailViewModels, id: \.id) { model in
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.grayF5F5F5)
                            
                            let isPaidBinding = Binding<Bool>(
                                get: { model.isPaid },
                                set: { newValue in
                                    viewModel.change(isPaid: newValue, for: model.id)
                                }
                            )
                            
                            InvoiceViewCell(
                                title: model.invoiceNumber,
                                dueDate: model.dueDate,
                                currency: model.currency,
                                totalPrice: model.total,
                                isInvoice: true,
                                isPaid: isPaidBinding)
                        }
                        .frame(height: 85)
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
                
                Text(viewModel.title)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}
