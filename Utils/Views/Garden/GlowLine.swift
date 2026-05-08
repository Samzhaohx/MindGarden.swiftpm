import SwiftUI

struct GlowLine: View {
    @State private var active = false
    @State private var dashPhase: CGFloat = 0

    private let glowColor = Color(red: 1.0, green: 0.97, blue: 0.93)

    var body: some View {
        ZStack {
            GlowFrameShape()
                .fill(glowColor.opacity(active ? 0.20 : 0.05))
                .mask(
                    GlowFrameShape()
                        .fill(Color.white)
                        .blur(radius: active ? 30 : 22)
                )
                .blur(radius: active ? 18 : 12)
                .compositingGroup()
                .blendMode(.plusLighter)

            GlowFrameShape()
                .stroke(
                    glowColor.opacity(active ? 0.35 : 0.0),
                    style: StrokeStyle(
                        lineWidth: active ? 18 : 12,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .blur(radius: active ? 18 : 13)
                .shadow(color: glowColor.opacity(active ? 0.55 : 0.0),
                        radius: active ? 26 : 18)
                .compositingGroup()
                .blendMode(.screen)

            GlowFrameShape()
                .stroke(
                    glowColor.opacity(0.38),
                    style: StrokeStyle(
                        lineWidth: 2.2,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [10, 10],
                        dashPhase: dashPhase
                    )
                )
                .blur(radius: 0.8)
                .shadow(color: glowColor.opacity(0.18), radius: 6)
                .compositingGroup()
                .blendMode(.plusLighter)
        }
        .drawingGroup()
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                active = true
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                dashPhase = -200
            }
        }
    }
}
