import SwiftUI

struct CoordinatorView: View {
    @StateObject private var coordinator = Coordinator()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabBarView()
                .navigationDestination(for: NavigationPathItem.self) { destination in
                    destination.destination()
                        .navigationBarBackButtonHidden(true)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { item in
                    item.content
                        .navigationBarBackButtonHidden(true)
                }
        }
        .environmentObject(coordinator)
    }
}
