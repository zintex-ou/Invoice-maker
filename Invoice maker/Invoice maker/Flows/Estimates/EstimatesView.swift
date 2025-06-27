import SwiftUI

struct EstimatesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = EstimatesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: .zero) {
                if viewModel.allEstimates.isEmpty {
                    emptyStateView
                } else {
                    estimateList
                }
                
            }
            
            HStack {
                Button("Create estimate") {
                    coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                        CreateInvoiceView(viewModel: .init(viewType: .createEstimate))
                    }
                }
                .buttonStyle(.main)
            }
            .padding(.vertical, 8)
            .background(.white)
        }
        .padding(.horizontal, 16)
    }
    
    private var estimateList: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(viewModel.allEstimates, id: \.id) { invoice in
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
                                isInvoice: invoice.isInvoice,
                                isPaid: isPaid) { isPaid in
                                    viewModel.change(isPaid: isPaid, for: id)
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
                    Image(.property1Estimates)
                }
            
            VStack(spacing: 4) {
                Text("Estimates")
                    .foregroundStyle(.black)
                    .font(.sans(style: .semiBold, size: 26))
                
                Text("Create your first estimate to give clients\na clear pricing preview.")
                    .foregroundStyle(.black767676)
                    .font(.sans(style: .regular, size: 16))
            }
            .multilineTextAlignment(.center)
            
            Spacer()
        }
    }
}

#Preview {
    EstimatesView()
}
