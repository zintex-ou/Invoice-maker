import SwiftUI

struct AddClientView: View {
    @Binding var nameError: Bool
    @Binding var eMailError: Bool
    @Binding var client: ClientInput
    
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack {
            ClientsExpandableTextFieldSection(
                mainFields: [
                    FormFieldSettings(
                        title: "Client name",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .default,
                        text: $client.clientName,
                        showError: $nameError
                    ),
                    FormFieldSettings(
                        title: "E-mail",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .emailAddress,
                        text: $client.email,
                        showError: $eMailError
                    ),
                    FormFieldSettings(
                        title: "Phone number",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .phonePad,
                        text: $client.phoneNumber,
                        showError: .constant(false)
                    ),
                    FormFieldSettings(
                        title: "Fax",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.fax,
                        showError: .constant(false)
                    )
                ],
                extraFields: [
                    FormFieldSettings(
                        title: "Country",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.country,
                        showError: .constant(false)
                    ),
                    FormFieldSettings(
                        title: "City",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.city,
                        showError: .constant(false)
                    ),
                    
                    FormFieldSettings(
                        title: "Street",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.street,
                        showError: .constant(false)
                    ),
                    
                    FormFieldSettings(
                        title: "Apartment",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.apartment,
                        showError: .constant(false)
                    ),
                    
                    FormFieldSettings(
                        title: "Postal code",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.postalCode,
                        showError: .constant(false)
                    )
                ],
                isExpanded: $isExpanded
            )
        }
    }
}

private struct ClientsExpandableTextFieldSection: View {
    let mainFields: [FormFieldSettings]
    let extraFields: [FormFieldSettings]
    @Binding var isExpanded: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(mainFields.indices, id: \.self) { index in
                    let field = mainFields[index]
                    CustomTextField(
                        title: field.title,
                        placeholder: field.placeholder,
                        isRequired: field.isRequired,
                        keyboardType: field.keyboardType,
                        text: field.text,
                        callError: field.showError
                    )
                }
                
                ToggleDetailsButton(isExpanded: $isExpanded)
                
                if isExpanded {
                    ForEach(extraFields.indices, id: \.self) { index in
                        let field = extraFields[index]
                        CustomTextField(
                            title: field.title,
                            placeholder: field.placeholder,
                            isRequired: field.isRequired,
                            keyboardType: field.keyboardType,
                            text: field.text,
                            callError: field.showError
                        )
                    }
                }
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
