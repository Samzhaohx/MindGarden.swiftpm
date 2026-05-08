import SwiftUI

struct ArticlesHelpButton: View {

    @State private var showHelp = false

    var body: some View {
        Button {
            showHelp = true
        } label: {
            Image(systemName: "questionmark")
                .font(.system(size: 15, weight: .semibold))
        }
        .mgGlassButtonStyleCompat()   
        .popover(
            isPresented: $showHelp,
            attachmentAnchor: .rect(.bounds),
            arrowEdge: .top
        ) {
            ArticlesHelpSheet()
                .frame(width: 320)
                .padding()
        }
    }
}
