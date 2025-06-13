import SwiftUI

struct PaywallView: View {
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var size: CGSize = .zero
    @Device private var device
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: .zero) {
                Spacer()
                
                VStack(spacing: .zero) {
                    VStack(spacing: 8) {
                        Text("Unlock\nall features now")
                            .font(.sans(style: .bold, size: 34))
                            .foregroundStyle(.black)
                    }
                    .multilineTextAlignment(.center)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(FeaturesContent.allCases, id: \.self) { item in
                            HStack(spacing: 17) {
                                Image(item.icon)
                                
                                Text(item.title)
                                    .foregroundStyle(.black)
                                    .font(.sans(style: .regular, size: 16))
                                
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 26)
                    
                    VStack(spacing: 10) {
                        ForEach(viewModel.products, id: \.productId) { product in
                            cell(product)
                                .onTapGesture {
                                    viewModel.selectedProduct = product
                                    viewModel.continueButtonText(product: product)
                                }
                        }
                    }
                    .padding(.top, 24)
                    
                    Button(viewModel.continueButtonText) {
                        withAnimation {
                            viewModel.tapOnContinue {
                                dismiss()
                            }
                        }
                    }
                    .buttonStyle(MainButton())
                    .modifier(PulseButton())
                    .padding(.top, 32)
                    
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
                            Task {
                                await viewModel.tapOnRestore {
                                    dismiss()
                                }
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
                    .padding(.top, 16)
                }
                .frame(maxWidth: device == .iPhone ? .infinity : 390)
            }
            .padding(.horizontal, 16)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            
            VStack {
                HStack {
                    if viewModel.shouldShowNotNowButton {
                        Button {
                            dismiss()
                        } label: {
                            Image(.property1Cross)
                                .renderingMode(.template)
                                .foregroundStyle(.black)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, device == .iPhone ? 0 : 24)
            }
            
            if viewModel.isLoading {
                LoadingView()
            }
        }
        .task {
            await viewModel.fetchPayWall()
        }
        .onAppear {
            viewModel.isNeedShowButton()
        }
        .animation(.default, value: viewModel.shouldShowNotNowButton)
        .animation(.default, value: viewModel.selectedProduct)
        .alert(
            viewModel.title,
            isPresented: $viewModel.shouldShowAlert) {
                
            } message: {
                Text(viewModel.subTitle)
            }
            .alert(
                viewModel.title,
                isPresented: $viewModel.shouldShowTryAgainAlert) {
                    Button("Cancel", role: .cancel) {
                        
                    }
                    
                    Button {
                        viewModel.tapOnContinue(completion: {
                            dismiss()
                        })
                    } label: {
                        Text("Try again")
                    }
                    
                } message: {
                    Text(viewModel.subTitle)
                }
    }
    
    @ViewBuilder
    func cell(_ model: SubscriptionModel) -> some View {
        ZStack(alignment: .topTrailing) {
            Capsule()
                .frame(maxWidth: .infinity, minHeight: 58, maxHeight: 58)
                .foregroundStyle(.white)
                .overlay {
                    HStack(spacing: 8) {
                        let isSelectedImage: ImageResource = viewModel.selectedProduct == model ? .checkBox : .uncheckBox
                        
                        Image(isSelectedImage)
                        
                        VStack(alignment: .leading) {
                            Text(model.nameProduct)
                                .foregroundStyle(.black)
                                .font(.sans(style: .regular, size: 16))
                        }
                        
                        Spacer()
                        
                        Text("\(model.currency)\(model.price, specifier: "%.2f")/\(model.period)")
                            .foregroundStyle(.black767676)
                            .font(.sans(style: .regular, size: 16))
                    }
                    .padding(.horizontal, 16)
                }
                .overlay(
                    Capsule()
                        .inset(by: 0.5)
                        .stroke(viewModel.selectedProduct == model ? .violet4663FF : .black767676, lineWidth: 1)
                )
            
            if let text = model.badgeText {
                let period = model.trialDays
                Text("\(period) \(text)")
                    .foregroundStyle(.white)
                    .font(.sans(style: .bold, size: 12))
                    .padding(6)
                    .background(.black)
                    .clipShape(Capsule())
                    .padding(.top, -14)
                    .padding(.trailing, 12)
            }
        }
        
    }
}

#Preview {
    PaywallView()
}
