enum Currency: String, CaseIterable {
    case USD
    case EUR
    case GBP
    case JPY
    case CNY
    case CAD
    case HKD
    case AUD
    case SGD
    case CHF
    case SEK
    case PLN
    case NOK
    case DKK
    case NZD
    case ZAR
    case MXN
    case THB
    case HUF
    case MYR
    case KRW
    case INR
    case BRL
    case RUB
    case TWD
    case TRY
    case IDR
    case AED
    case SAR
    case COP
    
    init(from raw: String?) {
        self = Currency(rawValue: raw ?? "USD") ?? .USD
    }
}
