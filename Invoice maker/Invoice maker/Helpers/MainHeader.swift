import SwiftUI

struct MainHeader: View {
    @Binding var isPremium: Bool
    var action: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text(UIApplication.shared.appName)
                .font(.sans(style: .semiBold, size: 20))
                .foregroundStyle(.black)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.leading)

            Spacer()

            if !isPremium {
                Button("Pro".uppercased()) { action() }
                    .buttonStyle(.premium)
            }
        }
        .frame(height: 48)
    }
}
