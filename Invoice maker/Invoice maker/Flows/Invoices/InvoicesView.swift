import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = InvoicesViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                MainHeader(isPremium: $viewModel.isPremium) {
                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                        PaywallView()
                    }
                }
                .padding(.top, 12)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    InvoicesView()
}
