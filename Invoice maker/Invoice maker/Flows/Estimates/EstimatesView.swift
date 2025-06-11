import SwiftUI

struct EstimatesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = EstimatesViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                MainHeader(isPremium: $viewModel.isPremium) {
//                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
//                        PaywallView()
//                    }
                }
                .padding(.top, 12)

                Spacer()

                Text("Estimates")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    EstimatesView()
}
