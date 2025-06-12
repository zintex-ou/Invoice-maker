import SwiftUI

struct ReportsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject private var viewModel = ReportsViewModel()

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

                Text("Reports")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ReportsView()
}
