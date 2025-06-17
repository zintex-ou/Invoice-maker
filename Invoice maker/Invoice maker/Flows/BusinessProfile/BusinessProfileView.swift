import SwiftUI

struct BusinessProfileView: View {
    @StateObject private var viewModel: BusinessProfileViewModel
    @EnvironmentObject private var coordinator: Coordinator
    
    init(viewModel: BusinessProfileViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            topView
            
            middleView
            
            bottomView
                .padding(.horizontal, -16)
        }
        .padding(.horizontal, 16)
        .photosPicker(
            isPresented: $viewModel.shouldShowPhotoPicker,
            selection: $viewModel.pickerItem,
            photoLibrary: .shared()
        )
        .onReceive(viewModel.$selectedImageData, perform: { newValue in
            if newValue != nil,viewModel.getGallerySelectionFlag() {
                viewModel.resetGallerySelectionFlag()
                coordinator.pushTo(id: EditPhotoView.navigationID) {
                    EditPhotoView(viewModel: viewModel)
                }
            }
        })
    }
    
    private var topView: some View {
        HStack {
            Spacer()
            
            Button {
                
            } label: {
                Text("Skip")
                    .foregroundStyle(.violet4663FF)
                    .font(.sans(style: .regular, size: 16))
                    .underline(true, pattern: .solid)
            }
            
        }
    }
    
    private var middleView: some View {
        ScrollView {
            VStack(spacing: .zero) {
                Text("Complete your business profile to continue.")
                    .font(.sans(style: .bold, size: 20))
                    .foregroundStyle(.black)
                
                Text("This data is required\nto finalize the invoice.")
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.black767676)
                    .padding(.top, 4)
                
                Circle()
                    .fill(.grayF5F5F5)
                    .frame(width: 131, height: 131)
                    .overlay {
                        if let imageData = viewModel.selectedImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 131, height: 131)
                                .clipShape(Circle())
                        } else {
                            Image(.property1AddPhoto)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            viewModel.tapOnPhoto()
                        } label: {
                            Circle()
                                .fill(.violet4663FF)
                                .frame(width: 36, height: 36)
                                .overlay {
                                    Image(viewModel.selectedImageData == nil ? .property1Plus : .property1Edit)
                                        .renderingMode(.template)
                                        .foregroundStyle(.white)
                                }
                                .overlay(content: {
                                    Circle()
                                        .stroke(.white, lineWidth: 4)
                                })
                        }
                    }
                    .padding(.top, 24)
                
                Spacer()
            }
            .padding(.top, 42)
            .padding(.horizontal, 16)
            .multilineTextAlignment(.center)
        }
        .scrollIndicators(.hidden)
    }
    
    private var bottomView: some View {
        HStack {
            Button("Continue") {
                
            }
            .buttonStyle(.main)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white)
    }
}

#Preview {
    BusinessProfileView(viewModel: .init(stateView: .createing))
}
