import SwiftUI

struct EstimatesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = EstimatesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                Spacer()
                
                emptyStateView
                
                Spacer()
            }
            
            Button("Create estimate") {
                coordinator.pushTo(id: CreateInvoiceView.navigationID) {
                    CreateInvoiceView(viewModel: .init(viewType: .createEstimate))
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
        }
    }
}

#Preview {
    EstimatesView()
}
