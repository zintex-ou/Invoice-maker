import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel = TabBarViewModel()

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        VStack(spacing: .zero) {
            MainHeader(isPremium: $viewModel.isPremium)
                .padding(.top, 12)
                .padding(.bottom, 4)

            TabView(selection: $viewModel.selectedIndex) {
                InvoicesView()
                    .tag(0)

                EstimatesView()
                    .tag(1)

                ReportsView()
                    .tag(2)

                SettingsView()
                    .tag(3)
            }

            tabBar
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var tabBar: some View {
        ZStack(alignment: .top) {
            RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                .foregroundStyle(.white)
                .frame(height: UIDevice.current.hasHomeButton ? 64 : 92)
                .overlay(
                    RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                        .stroke(LinearGradient.tabBarStroke, lineWidth: 1)
                )

            HStack(alignment: .center, spacing: 0) {
                tabBarItem
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    private var tabBarItem: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabBarItem.allCases.enumerated()), id: \.1) { index, item in
                let isSelected = item.rawValue == viewModel.selectedIndex
                let width: CGFloat = isSelected ? 138 : 48

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.tapOnTabBarItem(at: item.rawValue)
                    }
                }) {
                    HStack(spacing: isSelected ? 4 : 0) {
                        ZStack {
                            Image(item.icon)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(isSelected ? .white : .black)
                                .opacity(isSelected ? 0 : 1)

                            Image(item.activeIcon)
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(isSelected ? .white : .black)
                                .opacity(isSelected ? 1 : 0)
                        }
                        .zIndex(1)

                        TabBarMaskedText(text: item.title, isVisible: isSelected)
                    }
                    .frame(width: width, height: 48)
                    .background(isSelected ? .black : .grayF5F5F5)
                    .mask(
                        Capsule()
                            .frame(width: width, height: 48)
                    )
                    .frame(width: width, height: 48)
                }
                .buttonStyle(.tabBar)

                if index < TabBarItem.allCases.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    TabBarView()
}
