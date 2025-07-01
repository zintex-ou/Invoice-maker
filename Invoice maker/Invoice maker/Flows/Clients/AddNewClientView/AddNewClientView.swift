import SwiftUI

struct AddNewClientView: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @StateObject var viewModel: AddNewClientViewModel
    
    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case clientName, mail, phoneNumber, fax, contry, city, street, postalCode, appartment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            navigationBar
                .padding(.bottom, 4)
            
            textFieldsView
            
            
            Button(viewModel.buttonTitle) {
                withAnimation {
                    viewModel.onSaveTapped {
                        coordinator.popToBack()
                    }
                }
            }
            .buttonStyle(.main)
            .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .alert("Delete client",
               isPresented: $viewModel.isShowDeleteAlert) {
            Button("Cancel", role: .cancel) {
                
            }
            
            Button("Delete", role: .destructive) {
                viewModel.deleteClient()
                coordinator.popToBack()
            }
            
        } message: {
            Text("Are you sure you want to delete this client? ")
        }
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
            Text("If you close this client, all changes will be lost.")
        }
        .alert(viewModel.alert.title,
               isPresented: $viewModel.showErrorAlert) {
            Button("Cancel", role: .cancel) {
                
            }
        } message: {
            Text(viewModel.alert.subtitle)
        }
    }
    
    private var navigationBar: some View {
        ZStack {
            HStack {
                Button("") {
                    viewModel.onCloseTapped() {
                        coordinator.popToBack()
                    }
                }
                .buttonStyle(.circle(.property1Arrow))
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text(viewModel.title)
                    .font(.sans(style: .semiBold, size: 20))
                    .foregroundStyle(.black)
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                if case .editing = viewModel.viewState {
                    Button("") {
                        viewModel.showDeleteAlert()
                    }
                    .buttonStyle(.distructiveCircle(.property1Trash))
                }
            }
        }
    }
    
    private var textFieldsView: some View {
            ClientsExpandableTextFieldSection(
                mainFields: [
                    FormFieldSettings(
                        title: "Client name",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .default,
                        text: $viewModel.clientName,
                        showError: $viewModel.nameError,
                        equals: FocusedField.clientName
                    ),
                    FormFieldSettings(
                        title: "E-mail",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .emailAddress,
                        text: $viewModel.email,
                        showError: $viewModel.eMailError,
                        equals: FocusedField.mail
                    ),
                    FormFieldSettings(
                        title: "Phone number",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .phonePad,
                        text: $viewModel.phoneNumber,
                        showError: .constant(false),
                        equals: FocusedField.phoneNumber
                    ),
                    FormFieldSettings(
                        title: "Fax",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .phonePad,
                        text: $viewModel.fax,
                        showError: .constant(false),
                        equals: FocusedField.fax
                    )
                ],
                extraFields: [
                    FormFieldSettings(
                        title: "Country",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.country,
                        showError: .constant(false),
                        equals: FocusedField.contry
                    ),
                    FormFieldSettings(
                        title: "City",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.city,
                        showError: .constant(false),
                        equals: FocusedField.city
                    ),
                    
                    FormFieldSettings(
                        title: "Street",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.street,
                        showError: .constant(false),
                        equals: FocusedField.street
                    ),
                    
                    FormFieldSettings(
                        title: "Apartment",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.apartment,
                        showError: .constant(false),
                        equals: FocusedField.appartment
                    ),
                    
                    FormFieldSettings(
                        title: "Postal code",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $viewModel.postalCode,
                        showError: .constant(false),
                        equals: FocusedField.postalCode
                    )
                ],
                isExpanded: $viewModel.isExpanded,
                focused: $focusedField
            )
    }
}
