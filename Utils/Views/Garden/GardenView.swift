import SwiftUI

struct GardenView: View {

    @State private var showFirstInteraction = false

    @State private var glowEnabled = false

    @State private var backgroundName: String = "background"

    var body: some View {
        ZStack {
            GardenBackground(imageName: backgroundName)
                .ignoresSafeArea()

            GardenOverlay(glowEnabled: $glowEnabled) {
                glowEnabled = false
                showFirstInteraction = true
            }
        }
        .fullScreenCover(isPresented: $showFirstInteraction) {
            FirstInteractionView {
                showFirstInteraction = false
            }
        }
    }
}
