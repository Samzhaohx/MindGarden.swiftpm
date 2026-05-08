import SwiftUI

struct GardenOverlay: View {
    @Binding var glowEnabled: Bool
    let onTapFirstInteraction: () -> Void

    @State private var showPrompt = false
    @State private var promptStep: Int = 0

    @State private var contentOpacity: CGFloat = 1.0

    private let promptYRatio: CGFloat = 0.42

    private var currentTitle: String {
        switch promptStep {
        case 0: return "There's a garden \nin every mind,\nLet us notice it"
        case 1: return "Shall we start with the sky?"
        default: return "The garden is waiting \nfor you to notice the night sky"
        }
    }

    private var currentSubtitle: String? {
        promptStep == 2 ? "After closing, tap the glowing area." : nil
    }

    private var currentActionStyle: MistPromptActionStyle {
        promptStep < 2 ? .next : .close
    }

    var body: some View {
        ZStack {
            if glowEnabled { GlowLine() }

            GlowFrameShape()
                .fill(Color.clear)
                .contentShape(GlowFrameShape())
                .onTapGesture {
                    guard glowEnabled else { return }

                    if showPrompt {
                        withAnimation(.easeInOut(duration: 0.35)) { showPrompt = false }
                    }
                    onTapFirstInteraction()
                }
                .ignoresSafeArea()

            GeometryReader { proxy in
                if showPrompt {
                    MistPromptView(
                        title: currentTitle,
                        subtitle: currentSubtitle,
                        actionStyle: currentActionStyle,
                        contentOpacity: contentOpacity
                    ) {
                        handlePromptAction()
                    }
                    .frame(maxWidth: 420)
                    .position(x: proxy.size.width * 0.5,
                              y: proxy.size.height * promptYRatio)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            glowEnabled = false

            promptStep = 0
            contentOpacity = 0

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.35)) { showPrompt = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.25)) { contentOpacity = 1 }
                }
            }
        }
    }

    private func handlePromptAction() {
        if promptStep < 2 {
            withAnimation(.easeInOut(duration: 0.18)) { contentOpacity = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                promptStep += 1
                withAnimation(.easeInOut(duration: 0.22)) { contentOpacity = 1 }
            }
        } else {
            let textFade: Double = 0.20
            let mistFade: Double = 0.35
            let glowFadeIn: Double = 0.25

            withAnimation(.easeInOut(duration: textFade)) { contentOpacity = 0 }

            DispatchQueue.main.asyncAfter(deadline: .now() + textFade) {
                withAnimation(.easeInOut(duration: mistFade)) { showPrompt = false }

                DispatchQueue.main.asyncAfter(deadline: .now() + mistFade) {
                    withAnimation(.easeInOut(duration: glowFadeIn)) {
                        glowEnabled = true
                    }
                }
            }
        }
    }
}
