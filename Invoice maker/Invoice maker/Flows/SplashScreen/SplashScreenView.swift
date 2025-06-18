import SwiftUI

struct SplashScreenView: View {
    @AppStorage(Constants.isOnboardingCompleted) var isOnboardingCompleted: Bool = false
    @AppStorage(Constants.isCreatedBusinessProfile) var isCreatedBusinessProfile: Bool = false
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var viewModel = SplashScreenViewModel()
    
    var body: some View {
        ZStack {
            Image(.crown)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            Task {
                try await viewModel.fetchConfig()
                
                await  MainActor.run {
                    if isOnboardingCompleted {
                        if isCreatedBusinessProfile {
                            viewModel.changeViewControllres(count: 2)
                            coordinator.pushTo(id: TabBarView.navigationID) {
                                TabBarView()
                            }
                        } else {
                            coordinator.pushTo(id: BusinessProfileView.navigationID) {
                                let viewModel = BusinessProfileViewModel(stateView: .createing)
                                return BusinessProfileView(viewModel: viewModel)
                            }
                        }
                    } else {
                        viewModel.changeViewControllres(count: 3)
                        coordinator.pushTo(id: OnboardingView.navigationID) {
                            OnboardingView()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
