import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
                }
        }
    }
}
