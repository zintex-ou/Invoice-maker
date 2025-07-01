import Foundation

extension String {
    func isValidEmail() -> Bool {
        let emailRegex = "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES[c] %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func isValidPunctuationAndNewlinesOnly() -> Bool {
        let pattern = "^[\\p{P}\\s\\n\\r]*$"
        return self.range(of: pattern, options: [.regularExpression]) != nil
    }
}
