import SwiftUI

struct GlowFrameShape: Shape {

    private let W: CGFloat = 2160
    private let H: CGFloat = 1440
    private let baseline: CGFloat = 690

    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width  / W
        let scaleY = rect.height / H

        let lineW: CGFloat = 2146.5
        let xOffset = (W - lineW) / 2

        let bottomStart = CGPoint(
            x: (xOffset +   0.0)  * scaleX,
            y: (baseline       )  * scaleY
        )
        let bottomC1 = CGPoint(
            x: (xOffset +  491.5) * scaleX,
            y: (baseline - 399.5) * scaleY
        )
        let bottomC2 = CGPoint(
            x: (xOffset + 1505.5) * scaleX,
            y: (baseline - 465.5) * scaleY
        )
        let bottomEnd = CGPoint(
            x: (xOffset + 2146.5) * scaleX,
            y: (baseline       )  * scaleY
        )

        let rightTop = CGPoint(
            x: (xOffset + 2146.5) * scaleX,
            y: 0
        )
        let leftTop = CGPoint(
            x: (xOffset +   0.0)  * scaleX,
            y: 0
        )

        var path = Path()
        path.move(to: bottomStart)
        path.addCurve(
            to: bottomEnd,
            control1: bottomC1,
            control2: bottomC2
        )
        path.addLine(to: rightTop)
        path.addLine(to: leftTop)
        path.addLine(to: bottomStart)
        
        return path
    }
}
