import Foundation

struct SubscriptionModel: Equatable {
    let productId: String
    let nameProduct: String
    let period: String
    let price: Float
    let currency: String
    let badgeText: String?
    let isFreeTrial: Bool
    let trialDays: Int
}
