import SwiftUI

struct AddNewItemServiceView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: AddNewItemServiceViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 24)
            
            AddItemServiceView(
                nameError: $viewModel.nameError,
                priceError: $viewModel.priceError,
                itemService: $viewModel.itemServiceInput,
                name: viewModel.nameFieldTitle,
                currency: viewModel.currency,
                title: viewModel.subtitle1,
                subtitle: viewModel.subtitle2
            )
        }
        .padding(.horizontal, 16)
        .alert("Save before leaving?",
               isPresented: $viewModel.showLeaveWithoutSavingAlert) {
            Button("Leave", role: .cancel) {
                coordinator.popToBack()
            }
            
            Button("Save", role: .destructive) {
                viewModel.onSaveTapped {
                    coordinator.popToBack()
                }
            }
            
        } message: {
            Text(viewModel.alertLeavewithoutSavingMessage)
        }
        .alert("Error",
               isPresented: $viewModel.showErrorAlert) {
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text(viewModel.errorAlertSubtitle)
        }
        .sheet(isPresented: $viewModel.sholdShowCurrencyPicker) {
            CurrencyPickerView(currency: $viewModel.currency)
                .presentationDetents([.large])
        }
    }
    
    var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    viewModel.onCloseTapped {
                        coordinator.dismissFullScreenCover()
                    }
                }
                .buttonStyle(.circle(.property1Cross))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text(viewModel.titleButtonTitle)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}
