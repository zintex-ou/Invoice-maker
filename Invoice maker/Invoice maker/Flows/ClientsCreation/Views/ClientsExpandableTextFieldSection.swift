import SwiftUI

struct AddClientView: View {
    @Binding var nameError: Bool
    @Binding var eMailError: Bool
    @Binding var client: ClientInput
    
    @Binding var isExpanded: Bool

    @FocusState private var focusedField: FocusedField?
    
    enum FocusedField {
        case clientName, mail, phoneNumber, fax, contry, city, street, postalCode, appartment
    }

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
                        showError: $nameError,
                        equals: FocusedField.clientName
                    ),
                    FormFieldSettings(
                        title: "E-mail",
                        placeholder: "",
                        isRequired: true,
                        keyboardType: .emailAddress,
                        text: $client.email,
                        showError: $eMailError,
                        equals: FocusedField.mail
                    ),
                    FormFieldSettings(
                        title: "Phone number",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .phonePad,
                        text: $client.phoneNumber,
                        showError: .constant(false),
                        equals: FocusedField.phoneNumber
                    ),
                    FormFieldSettings(
                        title: "Fax",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.fax,
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
                        text: $client.country,
                        showError: .constant(false),
                        equals: FocusedField.contry
                    ),
                    FormFieldSettings(
                        title: "City",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.city,
                        showError: .constant(false),
                        equals: FocusedField.city
                    ),
                    
                    FormFieldSettings(
                        title: "Street",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.street,
                        showError: .constant(false),
                        equals: FocusedField.street
                    ),
                    
                    FormFieldSettings(
                        title: "Apartment",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.apartment,
                        showError: .constant(false),
                        equals: FocusedField.appartment
                    ),
                    
                    FormFieldSettings(
                        title: "Postal code",
                        placeholder: "",
                        isRequired: false,
                        keyboardType: .default,
                        text: $client.postalCode,
                        showError: .constant(false),
                        equals: FocusedField.postalCode
                    )
                ],
                isExpanded: $isExpanded,
                focused: $focusedField
            )
        }
    }
}

private struct ClientsExpandableTextFieldSection<Value: Hashable>: View {
    let mainFields: [FormFieldSettings<Value>]
    let extraFields: [FormFieldSettings<Value>]
    @Binding var isExpanded: Bool
    
    @FocusState.Binding var focused: Value?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(mainFields.indices, id: \.self) { index in
                    let field = mainFields[index]
                    CustomTextField(
                        focused: $focused,
                        equals: field.equals,
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
                            focused: $focused,
                            equals: field.equals,
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
