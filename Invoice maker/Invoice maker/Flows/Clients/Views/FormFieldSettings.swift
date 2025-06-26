import SwiftUI

struct FormFieldSettings<Value: Hashable> {
    let title: String
    let placeholder: String
    let isRequired: Bool
    let keyboardType: UIKeyboardType
    let text: Binding<String>
    let showError: Binding<Bool>
    let equals: Value
}
