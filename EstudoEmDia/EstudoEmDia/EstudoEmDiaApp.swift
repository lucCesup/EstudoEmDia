import SwiftUI

@main
struct EstudoEmDiaApp: App {
    // O AppDelegate cuida do Firebase e das notificações; o SwiftUI sozinho não tem esses ganchos.
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
