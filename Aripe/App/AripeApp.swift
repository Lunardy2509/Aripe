import SwiftUI

@main
struct AripeApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                NavigationStack {
                    MainView()
                }
            } else {
                OnBoardingView(onFinished: {
                    hasSeenOnboarding = true
                })
            }
        }
    }
}
