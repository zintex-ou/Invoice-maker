import SwiftUI

struct MainHeader: View {
    @EnvironmentObject private var coordinator: Coordinator
    
    @Binding var isPremium: Bool
    
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
                Button("Pro".uppercased()) {
                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                        PaywallView()
                    }
                }
                .buttonStyle(.premium)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
}
