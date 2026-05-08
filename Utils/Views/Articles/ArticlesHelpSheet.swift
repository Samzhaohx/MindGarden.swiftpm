import SwiftUI

struct ArticlesHelpSheet: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About this page")
                .font(.headline)
            
            Text("Here you can read about cognitive health, family support, and the thinking behind Mind Garden.")
                .font(.subheadline)
            
            Text("Please note: this content is for reflection only and is not medical advice or a diagnosis. It is meant to help families understand cognition more gently and start a conversation.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}
