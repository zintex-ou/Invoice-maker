import SwiftUI

struct EditPhotoView: View {
    @ObservedObject var viewModel: BusinessProfileViewModel
    @EnvironmentObject var coordinator: Coordinator
    
    var body: some View {
        VStack(spacing: .zero) {
            topView
            
            middleView
            
            bottomView
        }
        .fullScreenCover(isPresented: $viewModel.shouldShowCropView) {
            ImageCropper(
                imageData: viewModel.selectedImageData,
                done: { imageData in
                    viewModel.setEditedImage(imageData)
                })
            .ignoresSafeArea()
        }
    }
    
    private var topView: some View {
        HStack {
            Button {
                coordinator.popToBack()
                viewModel.resetImage()
            } label: { }
                .buttonStyle(.circle(.property1Arrow))
            
            Spacer()
            
            Button {
                viewModel.tapOnCrop()
            } label: { }
                .buttonStyle(.circle(.property1Crop))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .background(.white)
    }
    
    private var middleView: some View {
        VStack(spacing: .zero) {
            Spacer()
            
            if let imageData = viewModel.selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
            
            Spacer()
        }
        .background(.grayF5F5F5)
    }
    
    private var bottomView: some View {
        HStack {
            Button("Continue") {
                coordinator.popToBack()
            }
            .buttonStyle(.main)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white)
    }
}

#Preview {
    EditPhotoView(viewModel: .init(stateView: .editing))
}
