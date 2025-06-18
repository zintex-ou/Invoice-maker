import SwiftUI

struct BusinessProfileView: View {
    @StateObject private var viewModel: BusinessProfileViewModel
    @EnvironmentObject private var coordinator: Coordinator
    @AppStorage(Constants.isCreatedBusinessProfile) var isCreatedBusinessProfile: Bool = false
    
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
            if newValue != nil, viewModel.getGallerySelectionFlag() {
                viewModel.resetGallerySelectionFlag()
                coordinator.pushTo(id: EditPhotoView.navigationID) {
                    EditPhotoView(viewModel: viewModel)
                }
            }
        })
        .sheet(isPresented: $viewModel.sholdShowCurrencyPicker) {
            CurrencyPickerView(currency: $viewModel.currency)
                .presentationDetents([.large])
        }
        .alert(
            viewModel.alert.title,
            isPresented: $viewModel.shouldShowError) {
                
            } message: {
                Text(viewModel.alert.subtitle)
            }

    }
    
    private var topView: some View {
        HStack {
            Spacer()
            
            Button {
                showHomeScreen()
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
                    .multilineTextAlignment(.center)
                
                Text("This data is required\nto finalize the invoice.")
                    .font(.sans(style: .regular, size: 16))
                    .foregroundStyle(.black767676)
                    .padding(.top, 4)
                    .multilineTextAlignment(.center)
                
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
                
                VStack(spacing: 12) {
                    CustomTextField(
                        title: "Owner name",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .default,
                        text: $viewModel.ownerName,
                        callError: $viewModel.shouldShowOwnerNameError
                    )
                    
                    CustomTextField(
                        title: "E-mail",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .emailAddress,
                        text: $viewModel.mail,
                        callError: $viewModel.shouldShowMailError
                    )
                    
                    CustomTextField(
                        title: "Phone number",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .phonePad,
                        text: $viewModel.phoneNumber,
                        callError: $viewModel.shouldShowPhoneNumberError
                    )
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                viewModel.tapOnMoreDetails()
                            }
                        } label: {
                            Text(viewModel.shouldShowFullList ? "Hide details" : "More details")
                                .foregroundStyle(.violet4663FF)
                                .font(.sans(style: .regular, size: 16))
                                .underline(true, pattern: .solid)
                        }
                        .padding(.vertical, 12)
                    }
                    
                    if viewModel.shouldShowFullList {
                        CustomTextField(
                            title: "Country",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .default,
                            text: $viewModel.country,
                            callError: .constant(false)
                        )
                        
                        CustomTextField(
                            title: "City",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .default,
                            text: $viewModel.city,
                            callError: .constant(false)
                        )
                        
                        CustomTextField(
                            title: "Street",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .default,
                            text: $viewModel.street,
                            callError: .constant(false)
                        )
                        
                        CustomTextField(
                            title: "Apartment",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .default,
                            text: $viewModel.apartment,
                            callError: .constant(false)
                        )
                        
                        CustomTextField(
                            title: "Postal code",
                            placeholder: "",
                            isRequired: false,
                            keyboardType: .decimalPad,
                            text: $viewModel.postcode,
                            callError: .constant(false)
                        )
                    }
                    
                    Button(viewModel.currency.rawValue) {
                        viewModel.tapOnCurrencyButton()
                    }
                    .buttonStyle(.disclosure(title: "Currency"))
                }
                .padding(.top, 12)
                .padding(.horizontal, -12)
            }
            .padding(.top, 42)
            .padding(.horizontal, 16)
            .transition(.move(edge: .bottom))
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
    
    private var bottomView: some View {
        HStack {
            Button("Continue") {
                withAnimation {
                    viewModel.tapOnSaveButton {
                        showHomeScreen()
                    }
                }
            }
            .buttonStyle(.main)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.white)
    }
    
    private func showHomeScreen() {
        isCreatedBusinessProfile = true
        coordinator.pushTo(id: TabBarView.navigationID) {
            TabBarView()
        }
    }
}

#Preview {
    BusinessProfileView(viewModel: .init(stateView: .createing))
}
