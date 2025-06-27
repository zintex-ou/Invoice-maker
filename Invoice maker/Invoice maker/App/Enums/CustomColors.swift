import SwiftUI

enum CustomColors: String, CaseIterable {
    case green
    case orange
    case blue
    case yellow
    case purple
    case mint
    
    var color: Color {
        switch self {
        case .green:
            return Color(red: 0.79, green: 0.96, blue: 0.7)
        case .orange:
            return Color(red: 0.97, green: 0.83, blue: 0.66)
        case .blue:
            return Color(red: 0.85, green: 0.88, blue: 1)
        case .yellow:
            return Color(red: 0.98, green: 0.97, blue: 0.85)
        case .purple:
            return Color(red: 0.89, green: 0.83, blue: 1)
        case .mint:
            return Color(red: 0.85, green: 0.98, blue: 0.97)
        }
    }
}
