import StoreKit
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var coordinator: Coordinator
    @Environment(\.requestReview) private var requestReview
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                MainHeader(isPremium: $viewModel.isPremium) {
                    coordinator.presentFullScreenCover(id: PaywallView.navigationID) {
                        PaywallView()
                    }
                }
                .padding(.top, 12)

                settingsList
            }
        }
        .padding(.horizontal, 16)
    }

    private var settingsList: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 29) {
                    ForEach(SettingSection.allCases, id: \.self) { section in
                        VStack(alignment: .leading, spacing: 14) {
                            if section.title != "" {
                                Text(section.title)
                                    .font(.sans(style: .semiBold, size: 26))
                                    .foregroundStyle(.black)
                            }

                            VStack(spacing: 12) {
                                ForEach(section.items.indices, id: \.self) { index in
                                    let tab = section.items[index]

                                    Button(tab.title) {
                                        switch tab {
                                        case .profile:
                                            coordinator.pushTo(id: BusinessProfileView.navigationID, destination: {
                                                BusinessProfileView(viewModel: .init(stateView: .editing))
                                            })
                                        case .clients:
                                            coordinator.pushTo(id: ClientsListView.navigationID, destination: {
                                                ClientsListView()
                                            })
                                        case .services:
                                            coordinator.pushTo(id: ItemsServicesListView.navigationID, destination: {
                                                ItemsServicesListView()
                                            })
                                        case .rate:
                                            requestReview()
                                        default:
                                            viewModel.tapOnSettingsButton(type: tab)
                                        }
                                    }
                                    .buttonStyle(.settings(tab.icon))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 28)
                .padding(.bottom, 72)
            }
            .scrollIndicators(.hidden)

            ListTopShadow()
        }
    }
}

#Preview {
    SettingsView()
}
