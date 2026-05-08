import SwiftUI

struct GlowLine2: View {
    @State private var active = false
    @State private var dashPhase: CGFloat = 0

    private let c = Color(
        red: 222.0/255.0,
        green: 157.0/255.0,
        blue: 115.0/255.0
    )

    var body: some View {
        ZStack {
            GlowFrameShape2()
                .fill(Color.clear)
                .overlay {
                    ZStack {
                        GlowFrameShape2().fill(glowGradient(center: .top,      endRadius: 520))
                        GlowFrameShape2().fill(glowGradient(center: .center,   endRadius: 560))
                        GlowFrameShape2().fill(glowGradient(center: .bottom,   endRadius: 520))
                        GlowFrameShape2().fill(glowGradient(center: .leading,  endRadius: 520))
                        GlowFrameShape2().fill(glowGradient(center: .trailing, endRadius: 520))
                    }
                }
                .blur(radius: active ? 24 : 18)
                .compositingGroup()
                .blendMode(.plusLighter)

            GlowFrameShape2()
                .stroke(
                    c.opacity(active ? 0.38 : 0.0),
                    style: StrokeStyle(lineWidth: active ? 18 : 12, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: active ? 18 : 13)
                .shadow(color: c.opacity(active ? 0.50 : 0.0), radius: active ? 26 : 18)
                .compositingGroup()
                .blendMode(.screen)

            GlowFrameShape2()
                .stroke(
                    c.opacity(0.4),
                    style: StrokeStyle(
                        lineWidth: 2.2,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [10, 10],
                        dashPhase: dashPhase
                    )
                )
                .blur(radius: 0.8)
                .shadow(color: c.opacity(0.18), radius: 6)
                .compositingGroup()
                .blendMode(.plusLighter)
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                active = true
            }
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                dashPhase = -200
            }
        }
    }

    private func glowGradient(center: UnitPoint, endRadius: CGFloat) -> RadialGradient {
        RadialGradient(
            stops: [
                .init(color: c.opacity(active ? 0.42 : 0.0), location: 0.0),
                .init(color: c.opacity(active ? 0.18 : 0.0), location: 0.60),
                .init(color: c.opacity(0.0),                location: 1.0)
            ],
            center: center,
            startRadius: 0,
            endRadius: endRadius
        )
    }
}
