import SwiftUI

struct ArticlesBGMButton: View {
    @AppStorage("bgmOn") private var bgmOn: Bool = true

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                bgmOn.toggle()
            }
            if bgmOn {
                BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
            } else {
                BGMPlayer.shared.stop()
            }
        } label: {
            Image(systemName: bgmOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 15, weight: .semibold))
                .contentTransition(
                    .symbolEffect(.replace.magic(fallback: .downUp.wholeSymbol), options: .nonRepeating)
                )
        }
        .mgGlassButtonStyleCompat() 
    }
}
