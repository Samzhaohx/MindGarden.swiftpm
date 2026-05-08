import SwiftUI

extension Color {
    static let mindGardenWarm = Color(
        red: 247.0 / 255.0,
        green: 205.0 / 255.0,
        blue: 183.0 / 255.0
    )
}

struct IntroCardView: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 18) {

            Text("Before we begin")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            VStack(spacing: 14) {

                Text("This is a gentle walk into Mind Garden.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("""
In this garden,
Attention, Short-term Memory,
and Cognitive Flexibility
leave traces, like plants growing.
""")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("""
There is no right or wrong.
Just a gentler way to sense
where your parents are today.
""")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("""
After completing the activities,
you can view today's Mind Report
""")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.80))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.40), radius: 4, x: 0, y: 2)
            }

            Text("""
If you want to know the thinking behind these activities,
read more in Articles.
""")
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.65))
            .multilineTextAlignment(.center)
            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
            .padding(.top, 4)

            Button(action: onClose) {
                Text("Ready")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background {
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.75))
                    }
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 40)
        .background {
            SoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 770, minHeight: 560)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Soft-edge solid card background
// Feather alpha edges; avoid blurring color to prevent glow.
// Inset fill restores full-opacity center.
private struct SoftEdgeSolidCardBackground: View {
    let cornerRadius: CGFloat

    // Edge feather width
    let feather: CGFloat

    // Feather blur radius
    let featherBlur: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape
                .fill(Color.mindGardenWarm)

            shape
                .inset(by: max(0, feather - 4))
                .fill(Color.mindGardenWarm)
        }
        .compositingGroup()

        // Alpha-only mask; no color blur.
        .mask(
            shape
                .fill(Color.white)
                .blur(radius: featherBlur)
        )

        // Shadow only; no highlight.
        .shadow(color: Color.black.opacity(0.20), radius: 22, x: 0, y: 12)
    }
}
