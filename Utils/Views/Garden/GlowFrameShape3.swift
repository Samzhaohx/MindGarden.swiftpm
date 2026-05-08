import SwiftUI

struct GlowFrameShape3: Shape {

    private let baseW: CGFloat = 2000
    private let baseH: CGFloat = 1333

    private let dx: CGFloat = 0
    private let dy: CGFloat = 877

    func path(in rect: CGRect) -> Path {
        let s = max(rect.width / baseW, rect.height / baseH)
        let xOff = (rect.width - baseW * s) * 0.5
        let yOff = (rect.height - baseH * s) * 0.5

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: xOff + (dx + x) * s,
                y: yOff + (dy + y) * s
            )
        }

        let bottomLocalY: CGFloat = baseH - dy

        let insetX: CGFloat = 51
        let insetBottom: CGFloat = 6

        var path = Path()

        path.move(to: p(0 + insetX, 0.5))
        path.addLine(to: p(479.5, 0.5))

        path.addCurve(
            to: p(849, 153),
            control1: p(525.283, 78.4997),
            control2: p(693.392, 140.466)
        )

        path.addCurve(
            to: p(849, 128),
            control1: p(846.527, 143.684),
            control2: p(846.396, 138.234)
        )

        path.addCurve(
            to: p(887, 160),
            control1: p(875.183, 134.864),
            control2: p(880.17, 143.526)
        )

        path.addCurve(
            to: p(1092, 160),
            control1: p(966.347, 162.32),
            control2: p(1011.18, 162.506)
        )

        path.addCurve(
            to: p(1127, 130.5),
            control1: p(1105.17, 143.062),
            control2: p(1112.82, 136.408)
        )

        path.addCurve(
            to: p(1126, 157.5),
            control1: p(1129.95, 131.587),
            control2: p(1128.98, 139.275)
        )

        path.addCurve(
            to: p(1517.5, 0.5),
            control1: p(1362.37, 130.588),
            control2: p(1485.17, 59.7129)
        )

        path.addLine(to: p(2000 - insetX, 0.5))

        path.addLine(to: p(2000 - insetX, bottomLocalY - insetBottom))

        path.addLine(to: p(0 + insetX, bottomLocalY - insetBottom))

        path.addLine(to: p(0 + insetX, 0.5))

        path.closeSubpath()
        return path
    }
}
