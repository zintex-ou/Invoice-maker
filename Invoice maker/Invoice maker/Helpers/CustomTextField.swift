import SwiftUI

struct CustomTextField<Value: Hashable>: View {
    enum FocusedField {
        case ownerName
    }
    
    @FocusState.Binding var focused: Value?
    let equals: Value
    
    let title: String
    let placeholder: String
    let isRequired: Bool
    let keyboardType: UIKeyboardType
    
    @Binding var text: String
    @Binding var callError: Bool
    
    private var borderColor: Color {
        if focused == equals {
            return .violet4663FF
        } else if callError && isRequired {
            return .redDF0101
        } else {
            return .clear
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            titleView
            
            textFieldView
            
            if isRequired && callError && text.isEmpty {
                error
            }
        }
    }
    
    private var titleView: some View {
        HStack(spacing: 2) {
            Text(title)
                .font(.sans(style: .regular, size: 12))
                .foregroundColor(.black767676)
            
            if isRequired {
                Text("*")
                    .foregroundColor(.violet4663FF)
                    .font(.sans(style: .regular, size: 12))
            }
        }
        .padding(.leading, 16)
    }
    
    private var textFieldView: some View {
        ZStack {
            Capsule()
                .fill(.grayF5F5F5)
                .frame(height: 48)
                .overlay {
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                }
            
            TextField(placeholder, text: $text)
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black)
                .tint(.black)
                .keyboardType(keyboardType)
                .submitLabel(.return)
                .textContentType(.emailAddress)
                .submitLabel(.done)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($focused, equals: equals)
                .overlay(alignment: .trailing) {
                    Button {
                        text = ""
                    } label: {
                        Image(.property1Cross)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.white)
                            .background {
                                Circle()
                                    .foregroundStyle(.violet4663FF)
                                    .frame(width: 20, height: 20)
                            }
                            .opacity(focused == equals && !text.isEmpty ? 1 : 0)
                            .animation(.linear(duration: 0.1), value: !text.isEmpty)
                            .animation(.linear(duration: 0.1), value: focused == equals)
                    }
                }
                .toolbar {
                    if focused == equals {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focused = nil
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
        }
        .animation(.linear(duration: 0.1), value: equals)
        .onChange(of: text) { _ in
            callError = false
        }
    }
    
    private var error: some View {
        Text("Please fill out this field.")
            .font(.sans(style: .regular, size: 12))
            .foregroundColor(.redDF0101)
            .padding(.leading, 16)
            .transition(.opacity)
            .animation(.linear(duration: 0.1), value: callError)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
    }
    
    private struct PreviewContainer: View {
        @State private var name = ""
        @State private var nameError = false
        
        @State private var phone = ""
        @State private var phoneError = false
        
        @FocusState private var focusedField: FocusedField?
        
        enum FocusedField {
            case name, phone
        }
        
        var body: some View {
            VStack(spacing: 12) {
                CustomTextField(
                    focused: $focusedField,
                    equals: .name,
                    title: "Owner name",
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .default,
                    text: $name,
                    callError: $nameError
                )
                
                CustomTextField(
                    focused: $focusedField,
                    equals: .phone,
                    title: "Phone number",
                    placeholder: "",
                    isRequired: false,
                    keyboardType: .phonePad,
                    text: $phone,
                    callError: $phoneError
                )
            }
            .padding()
        }
    }
}
