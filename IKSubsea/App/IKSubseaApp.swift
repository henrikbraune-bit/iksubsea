import SwiftUI

@main
struct IKSubseaApp: App {

    @State private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(coordinator)
                .preferredColorScheme(.dark)
        }
    }
}
