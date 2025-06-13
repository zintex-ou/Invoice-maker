import StoreKit
import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var tabSelection: Int = 0
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var coordinator: Coordinator
    @AppStorage(Constants.isOnboardingCompleted) var isOnboardingCompleted: Bool = false
    
    @Device private var device
    
    var body: some View {
        ZStack(alignment: .top) {
            Image(viewModel.metaData[tabSelection].image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            
            VStack(spacing: .zero) {
                Spacer()
                
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        ForEach(0 ... viewModel.metaData.count, id: \.self) { index in
                            let isSelected = index == tabSelection
                            
                            Circle()
                                .fill(isSelected ? .violet4663FF : .black767676.opacity(0.4))
                                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    Text(viewModel.metaData[tabSelection].title)
                        .foregroundStyle(.black)
                        .font(.sans(style: .semiBold, size: 26))
                        .padding(.top, 16)
                    
                    Text(viewModel.metaData[tabSelection].subtitle)
                        .foregroundStyle(.black767676)
                        .font(.sans(style: .regular, size: 16))
                        .padding(.top, 8)
                    
                    Button(tabSelection == 3 ? viewModel.continueButtonText() : "Continue") {
                        tapOnContinue()
                    }
                    .buttonStyle(.main)
                    .modifier(PulseButton())
                    .padding(.top, 24)
                    
                    HStack {
                        Text("by continuining, you agree to:")
                        
                        Spacer()
                        
                        Button {
                            UIApplication.shared.openPrivacy()
                        } label: {
                            Text("Privacy")
                                .underline()
                        }
                        
                        Spacer()
                        
                        Button {
                            viewModel.tapOnRestore {
                                closeAction()
                            }
                        } label: {
                            Text("Restore")
                                .underline()
                        }
                        
                        Spacer()
                        
                        Button {
                            UIApplication.shared.openTerms()
                        } label: {
                            Text("Terms")
                                .underline()
                        }
                    }
                    .font(.sans(style: .regular, size: 12))
                    .foregroundStyle(.black767676)
                    .padding(.top, 14)
                    .opacity(tabSelection == 3 ? 1 : 0)
                }
                .padding(.top, 26)
                .padding(.horizontal, 16)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.white)
                }
            }
            
            VStack {
                HStack {
                    if viewModel.shouldShowCloseButton {
                        Button {
                            closeAction()
                        } label: {
                            Image(.property1Cross)
                                .renderingMode(.template)
                                .foregroundStyle(.black)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .opacity(tabSelection == 3 ? 1 : 0)
        }
        .onChange(of: tabSelection) { tabSelection in
            if tabSelection == 1 {
                if RemoteConfigManager.shared.config.enabledAppRatingRequest {
                    requestReview()
                }
            } else if tabSelection == 3 {
                viewModel.showCloseButton()
            }
        }
        .task {
            await viewModel.fetchPayWall()
        }
        .alert(
            viewModel.title,
            isPresented: $viewModel.shouldShowAlert) {} message: {
            Text(viewModel.subTitle)
        }
        .alert(
            viewModel.title,
            isPresented: $viewModel.shouldShowTryAgainAlert)
        {
            Button("Cancel", role: .cancel) {}
                    
            Button {
                Task {
                    await viewModel.makePurchase(completion: {
                        closeAction()
                    })
                }
            } label: {
                Text("Try again")
            }
                    
        } message: {
            Text(viewModel.subTitle)
        }
        .loading(isPresented: $viewModel.isLoading)
    }
}

#Preview {
    OnboardingView()
}

extension OnboardingView {
    private func tapOnContinue() {
        withAnimation {
            if tabSelection != viewModel.metaData.count - 1 {
                tabSelection += 1
            } else {
                Task {
                    await viewModel.makePurchase(completion: {
                        closeAction()
                    })
                }
            }
        }
    }
    
    private func closeAction() {
        isOnboardingCompleted = true
        
        coordinator.pushTo(id: TabBarView.navigationID) {
            TabBarView()
        }
    }
}

struct PulseButton: ViewModifier {
    @State private var enablePulse: Bool = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(enablePulse ? 0.95 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    enablePulse.toggle()
                }
            }
    }
}
