import SwiftUI

struct TabBarView: View {
    @StateObject private var viewModel = TabBarViewModel()

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
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
                .frame(height: 92)

            HStack(alignment: .center, spacing: 0) {
                tabBarItem
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .overlay(
                RoundedCorners(radius: 25, corners: [.topLeft, .topRight])
                    .stroke(LinearGradient.tabBarStroke, lineWidth: 1)
            )
        }
    }

    private var tabBarItem: some View {
        HStack(spacing: 0) {
            ForEach(Array(TabBarItem.allCases.enumerated()), id: \.1) { index, item in
                Button(action: {
                    viewModel.tapOnTabBarItem(at: item.rawValue)
                }) {
                    ZStack {
                        Capsule()
                            .foregroundStyle(item.rawValue == viewModel.selectedIndex ? .black : .grayF5F5F5)
                            .frame(width: item.rawValue == viewModel.selectedIndex ? 138 : 48, height: 48)

                        HStack(spacing: 4) {
                            Image(item.rawValue == viewModel.selectedIndex ? item.activeIcon : item.icon)
                                .renderingMode(.template)
                                .foregroundStyle(item.rawValue == viewModel.selectedIndex ? .white : .black)

                            if item.rawValue == viewModel.selectedIndex {
                                Text(item.title)
                                    .font(.sans(style: .semiBold, size: 12))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .animation(.linear(duration: 0.3), value: item.rawValue)
                }

                if index < TabBarItem.allCases.count - 1 {
                    Spacer()
                }
            }
        }
    }
}
