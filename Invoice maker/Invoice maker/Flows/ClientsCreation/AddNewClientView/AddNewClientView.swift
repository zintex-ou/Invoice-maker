import SwiftUI

struct AddNewClientView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: AddNewClientViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 14)
            
            ScrollView {
                VStack(spacing: 12) {
                    CustomTextField(
                        title: "Client name",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .default,
                        text: $viewModel.clientName,
                        callError: $viewModel.nameError
                    )
                    
                    CustomTextField(
                        title: "E-mail",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .emailAddress,
                        text: $viewModel.eMail,
                        callError: $viewModel.eMailError
                    )
                    
                    CustomTextField(
                        title: "Phone number",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .phonePad,
                        text: $viewModel.phoneNumber,
                        callError: .constant(false)
                    )
                    
                    CustomTextField(
                        title: "Fax",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.fax,
                        callError: .constant(false)
                    )
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.isAllFields.toggle()
                    } label: {
                        Text(viewModel.isAllFields ? "Hide details" : "More details")
                            .font(.sans(style: .regular, size: 16))
                            .foregroundStyle(.violet4663FF)
                            .underline()
                    }
                }
                .padding(.bottom, 12)
                
                if viewModel.isAllFields {
                    VStack(spacing: 12) {
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
                            keyboardType: .default,
                            text: $viewModel.postalCode,
                            callError: .constant(false)
                        )
                    }
                }
            }
            
            Button("Add new client") {
                withAnimation {
                    if !viewModel.validateFields() {
                        viewModel.saveClient()
                        coordinator.dismissFullScreenCover()
                    }
                }
            }
            .buttonStyle(MainButton())
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
    }
    
    var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    coordinator.dismissFullScreenCover()
                }
                    .buttonStyle(.circle(.property1Cross))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Add new client")
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
        }
    }
}

#Preview {
    AddNewClientView()
}
