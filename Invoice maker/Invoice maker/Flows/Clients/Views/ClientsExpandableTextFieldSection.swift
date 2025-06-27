import SwiftUI

struct ClientsExpandableTextFieldSection<Value: Hashable>: View {
    let mainFields: [FormFieldSettings<Value>]
    let extraFields: [FormFieldSettings<Value>]
    @Binding var isExpanded: Bool
    
    @FocusState.Binding var focused: Value?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
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
            .padding(.top, 24)
            .transition(.move(edge: .bottom))
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
