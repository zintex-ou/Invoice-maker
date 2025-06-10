import SwiftUI

extension Font {
    static func sans(
        style: FontsWeight,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle = .body) -> Font
    {
        let fontName: String = RethinkSansFont.rethinkSans.rawValue + style.rawValue
        return Font.custom(fontName, size: size, relativeTo: textStyle)
    }
}
