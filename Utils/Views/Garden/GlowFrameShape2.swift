import SwiftUI

struct GlowFrameShape2: Shape {

    private let W: CGFloat = 2160
    private let H: CGFloat = 1440

    func path(in rect: CGRect) -> Path {
        let scale = max(rect.width / W, rect.height / H)
        let xOffset = (rect.width  - W * scale) * 0.5
        let yOffset = (rect.height - H * scale) * 0.5

        let ox: CGFloat = 514.5
        let oy: CGFloat = 386.5

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: (x + ox) * scale + xOffset,
                y: (y + oy) * scale + yOffset
            )
        }

        var path = Path()

        // --- SVG Path ---
        path.move(to: p(135.0, 241.216))
        path.addLine(to: p(154.5, 268.216))
        path.addLine(to: p(170.0, 301.716))
        path.addLine(to: p(198.0, 247.716))
        path.addCurve(to: p(219.0, 207.216), control1: p(202.775, 227.738), control2: p(202.046, 212.399))
        path.addCurve(to: p(242.0, 197.216), control1: p(218.954, 187.859), control2: p(223.455, 184.755))
        path.addLine(to: p(283.5, 189.716))
        path.addLine(to: p(323.0, 189.716))
        path.addLine(to: p(324.5, 173.216))
        path.addLine(to: p(336.0, 185.716))
        path.addLine(to: p(343.0, 173.216))
        path.addLine(to: p(348.5, 185.716))
        path.addLine(to: p(361.0, 178.216))
        path.addLine(to: p(394.5, 202.216))
        path.addCurve(to: p(440.0, 141.716), control1: p(341.623, 184.373), control2: p(384.682, 127.336))
        path.addCurve(to: p(499.5, 80.7163), control1: p(414.468, 87.4773), control2: p(454.429, 35.771))
        path.addLine(to: p(499.5, 42.2163))
        path.addLine(to: p(515.5, 52.2163))
        path.addLine(to: p(536.5, 25.2163))
        path.addLine(to: p(540.5, 10.7163))
        path.addLine(to: p(547.5, 20.7163))
        path.addLine(to: p(566.5, 0.716293))
        path.addLine(to: p(591.0, 25.2163))
        path.addLine(to: p(610.0, 15.2163))
        path.addLine(to: p(616.5, 37.2163))
        path.addLine(to: p(634.0, 66.2163))
        path.addCurve(to: p(702.5, 115.216), control1: p(670.409, 39.0596), control2: p(712.941, 46.3226))
        path.addCurve(to: p(754.0, 164.716), control1: p(746.454, 104.226), control2: p(772.642, 111.821))
        path.addLine(to: p(758.5, 176.716))
        path.addLine(to: p(772.5, 176.716))
        path.addLine(to: p(778.0, 176.716))
        path.addLine(to: p(788.5, 185.716))
        path.addLine(to: p(794.0, 171.216))
        path.addLine(to: p(801.0, 180.716))
        path.addLine(to: p(809.0, 174.216))
        path.addLine(to: p(855.0, 189.716))
        path.addCurve(to: p(894.5, 197.216), control1: p(855.0, 189.716), control2: p(881.492, 207.253))
        path.addCurve(to: p(918.5, 207.216), control1: p(907.508, 187.18), control2: p(915.962, 186.948))
        path.addCurve(to: p(943.5, 247.716), control1: p(931.645, 211.11), control2: p(935.381, 226.102))
        path.addLine(to: p(968.5, 301.716))
        path.addLine(to: p(983.5, 268.216))
        path.addLine(to: p(997.0, 258.216))

        path.addCurve(to: p(993.5, 247.716), control1: p(989.534, 264.3), control2: p(997.325, 258.534))

        path.addLine(to: p(1007.0, 241.216))
        path.addLine(to: p(1018.5, 247.716))
        path.addLine(to: p(1027.5, 241.216))
        path.addLine(to: p(1044.0, 241.216))
        path.addLine(to: p(1044.0, 258.216))
        path.addLine(to: p(1060.0, 268.216))
        path.addLine(to: p(1060.0, 301.716))
        path.addLine(to: p(1067.5, 339.216))
        path.addLine(to: p(1060.0, 379.216))
        path.addCurve(to: p(1131.5, 471.216), control1: p(1108.75, 408.955), control2: p(1123.76, 426.439))
        path.addLine(to: p(1131.5, 549.216))
        path.addCurve(to: p(0.5, 549.216), control1: p(1036.16, 772.1), control2: p(162.282, 814.974))
        path.addLine(to: p(0.5, 485.216))
        path.addCurve(to: p(78.0, 375.216), control1: p(0.868556, 433.218), control2: p(17.8846, 409.148))
        path.addCurve(to: p(71.5, 339.216), control1: p(68.7625, 362.04), control2: p(67.2208, 354.178))
        path.addLine(to: p(78.0, 308.216))
        path.addLine(to: p(78.0, 268.216))
        path.addLine(to: p(93.0, 258.216))
        path.addLine(to: p(93.0, 241.216))
        path.addLine(to: p(105.0, 241.216))
        path.addLine(to: p(119.0, 247.716))
        path.addLine(to: p(126.5, 241.216))

        path.closeSubpath()
        return path
    }
}


