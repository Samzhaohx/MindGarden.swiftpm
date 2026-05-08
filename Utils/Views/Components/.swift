import SwiftUI

struct GlobalMagicButton: View {
    let action: () -> Void

    @State private var toggled = false

    var body: some View {
        Button {
            toggled.toggle()
            action()
        } label: {
            Image(systemName: toggled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 18, weight: .semibold))
                .contentTransition(
                    .symbolEffect(.replace.magic(fallback: .downUp.wholeSymbol), options: .nonRepeating)
                )
                .frame(width: 52, height: 52)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().fill(Color.black.opacity(0.18)))
                )
                .overlay(
                    Circle().stroke(Color.white.opacity(0.45), lineWidth: 1.4)
                )
                .shadow(color: Color.black.opacity(0.32), radius: 12, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}
