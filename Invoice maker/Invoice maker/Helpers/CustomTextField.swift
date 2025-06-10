import SwiftUI

struct CustomTextField: View {
    @FocusState private var isFocused: Bool
    
    let title: String
    let placeholder: String
    let isRequired: Bool
    let keyboardType: UIKeyboardType
   
    @Binding var text: String
    @Binding var callError: Bool
    
    private var borderColor: Color {
        if isFocused {
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
                .fill(.greyF5F5F5)
                .frame(height: 48)
                .overlay {
                    Capsule()
                        .stroke(borderColor, lineWidth: 1)
                }
            
            TextField(placeholder, text: $text)
                .font(.sans(style: .regular, size: 16))
                .foregroundStyle(.black)
                .keyboardType(keyboardType)
                .textContentType(.emailAddress)
                .submitLabel(.done)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isFocused)
                .overlay(alignment: .trailing) {
                    Button {
                        text = ""
                    } label: {
                        Image(.property1Cross)
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.white)
                            .background {
                                Circle()
                                    .fill(.violet4663FF)
                            }
                            .opacity(isFocused && !text.isEmpty ? 1 : 0)
                    }
                }
                .padding(.horizontal, 16)
        }
        .onChange(of: text) { newValue in
            callError = false
        }
    }
    
    private var error: some View {
        Text("Please fill out this field.")
            .font(.sans(style: .regular, size: 12))
            .foregroundColor(.redDF0101)
            .padding(.leading, 16)
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer()
            .previewLayout(.sizeThatFits)
    }
    
    private struct PreviewContainer: View {
        @State private var name = ""
        @State private var nameError = false
        
        @State private var phone = ""
        @State private var phoneError = false
        
        var body: some View {
            VStack(spacing: 12) {
                CustomTextField(
                    title: "Owner name",
                    placeholder: "",
                    isRequired: true,
                    keyboardType: .default,
                    text: $name,
                    callError: $nameError
                )
                
                CustomTextField(
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
