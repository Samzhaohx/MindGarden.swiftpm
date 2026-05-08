import SwiftUI

// MARK: - Public API

enum MistPromptActionStyle {
    case next   // chevron.right
    case close  // xmark
}

struct MistPromptView: View {
    let title: String
    let subtitle: String?
    let actionStyle: MistPromptActionStyle
    let contentOpacity: CGFloat
    let onAction: () -> Void

    @State private var phase: CGFloat = 0

    init(
        title: String,
        subtitle: String? = nil,
        actionStyle: MistPromptActionStyle,
        contentOpacity: CGFloat = 1.0,
        onAction: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.actionStyle = actionStyle
        self.contentOpacity = contentOpacity
        self.onAction = onAction
    }

    var body: some View {
        VStack(spacing: 6) {

            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 25, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: Color.black.opacity(0.55), radius: 6, y: 2)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.62))
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .shadow(color: Color.black.opacity(0.55), radius: 6, y: 2)
                }

                actionButton
            }
            .opacity(contentOpacity)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 14)
        .frame(minWidth: 120, minHeight: 260)

        .mgGlassEffectCompat(in: MistBlobShape(phase: phase).inset(by: -10))
        .overlay {
            MistBlobShape(phase: phase).inset(by: -14)
                .fill(Color.white.opacity(0.12))
                .blur(radius: 14)
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
        .shadow(color: Color.black.opacity(0.14), radius: 18, y: 8)
        .accessibilityElement(children: .combine)
        .onAppear {
            withAnimation(.linear(duration: 9).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }

    private var actionButton: some View {
        Button {
            onAction()
        } label: {
            Image(systemName: actionStyle == .next ? "chevron.right" : "xmark")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.65))
                .padding(.top, 20)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)

    }
}

// MARK: - Mist Shape

private struct MistBlobShape: InsettableShape {
    var phase: CGFloat
    var insetAmount: CGFloat = 0

    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { .init(phase, insetAmount) }
        set { phase = newValue.first; insetAmount = newValue.second }
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let center = CGPoint(x: r.midX, y: r.midY)
        let baseR = min(r.width, r.height) * 0.72

        let count = 14
        let twoPi = CGFloat.pi * 2
        let p = phase * twoPi

        func radius(_ a: CGFloat) -> CGFloat {
            let r1 = 0.10 * sin(a * 3 + p)
            let r2 = 0.06 * sin(a * 5 - p * 1.2)
            let r3 = 0.04 * sin(a * 2 + p * 0.7)
            return baseR * (1 + r1 + r2 + r3)
        }

        var points: [CGPoint] = []
        points.reserveCapacity(count)

        for i in 0..<count {
            let a = twoPi * CGFloat(i) / CGFloat(count)
            let rr = radius(a)
            points.append(.init(x: center.x + rr * cos(a),
                                y: center.y + rr * sin(a)))
        }

        var path = Path()
        guard points.count >= 2 else { return path }

        func catmullRom(_ p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint, _ t: CGFloat) -> CGPoint {
            let t2 = t * t
            let t3 = t2 * t
            let x = 0.5 * (2*p1.x + (-p0.x + p2.x)*t + (2*p0.x - 5*p1.x + 4*p2.x - p3.x)*t2 + (-p0.x + 3*p1.x - 3*p2.x + p3.x)*t3)
            let y = 0.5 * (2*p1.y + (-p0.y + p2.y)*t + (2*p0.y - 5*p1.y + 4*p2.y - p3.y)*t2 + (-p0.y + 3*p1.y - 3*p2.y + p3.y)*t3)
            return CGPoint(x: x, y: y)
        }

        path.move(to: points[0])

        let n = points.count
        let samples = 8
        for i in 0..<n {
            let p0 = points[(i - 1 + n) % n]
            let p1 = points[i]
            let p2 = points[(i + 1) % n]
            let p3 = points[(i + 2) % n]

            for s in 1...samples {
                let t = CGFloat(s) / CGFloat(samples)
                path.addLine(to: catmullRom(p0, p1, p2, p3, t))
            }
        }

        path.closeSubpath()
        return path
    }
}
