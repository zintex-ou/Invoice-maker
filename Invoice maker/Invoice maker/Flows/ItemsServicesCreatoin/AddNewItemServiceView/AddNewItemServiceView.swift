import SwiftUI

struct AddNewItemServiceView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: AddNewItemServiceViewModel
    
#warning("Change curency dinamically")
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 24)
            
            AddItemServiceView(
                nameError: $viewModel.nameError,
                priceError: $viewModel.priceError,
                itemService: $viewModel.itemServiceInput,
                name: viewModel.nameFieldTitle,
                currency: .USD,
                title: viewModel.subtitle1,
                subtitle: viewModel.subtitle2
            )
            
            Button(viewModel.titleButtonTitle) {
                viewModel.onSaveTapped {
                    coordinator.dismissFullScreenCover()
                }
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .alert("Save before leaving?",
               isPresented: $viewModel.showLeaveWithoutSavingAlert) {
            Button("Leave", role: .cancel) {
                coordinator.dismissFullScreenCover()
            }
            
            Button("Save", role: .destructive) {
                viewModel.onSaveTapped {
                    coordinator.dismissFullScreenCover()
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
