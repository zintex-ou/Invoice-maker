enum DiscountType: String, CaseIterable {
    case none = "None"
    case percentage = "Percentage"
    case flatAmount = "Flat amount"
    
    init(from raw: String?) {
        self = DiscountType(rawValue: raw ?? "None") ?? .none
    }
}
