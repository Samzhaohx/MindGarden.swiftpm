import SwiftUI

struct MindReportView: View {
    let onClose: () -> Void

    @AppStorage("bgmOn") private var bgmOn: Bool = true

    var body: some View {
        ZStack {
            Color.FCEDE2
                .ignoresSafeArea()

            GeometryReader { geo in
                mindReportContent(geo: geo)
            }
        }
    }

    @ViewBuilder
    private func mindReportContent(geo: GeometryProxy) -> some View {
        ZStack {
            let topPad = geo.safeAreaInsets.top

            ScrollView(showsIndicators: false) {
                ReportChartView()
                    .padding(.top, topPad + 72)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            let safeTop: CGFloat = 14
            let topBarHeight: CGFloat = 52 + safeTop + 12

            VStack(spacing: 0) {
                ZStack {
                    Color.FCEDE2
                        .ignoresSafeArea(edges: .top)

                    HStack {
                        MindReportGlassIconButton(
                            systemName: "chevron.left",
                            action: { onClose() }
                        )
                        .padding(.leading, 20)
                        .padding(.top, safeTop)

                        Spacer()

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
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(.white)
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
                        .padding(.trailing, 20)
                        .padding(.top, safeTop)
                    }

                    Text("Today's Mind Report")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.72))
                        .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 8)
                        .frame(height: 52)
                        .padding(.top, safeTop)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                }
                .frame(height: topBarHeight)

                Spacer(minLength: 0)
            }
            .zIndex(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct MindReportGlassIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
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
private struct ReportChartView: View {
    private let floorH: CGFloat = 0.30

    private let tFull: Double = 20
    private let tBandLow: Double = 30
    private let tBandHigh: Double = 45
    private let tFloor: Double = 120

    var body: some View {
        let m = MindGardenMetricsStore.shared.latest()

        let starT = m?.starsTimeS
        let petalNonTarget = Double(m?.petalNonTargetTaps ?? 0)
        let vineCorrect = Double(m?.vineCorrectTaps ?? 0)
        let vineNonTarget = Double(m?.vineNonTargetTaps ?? 0)
        let vineEarly = Double(m?.vineEarlyTaps ?? 0)

        let petalScore = clamp(6.0 - petalNonTarget, 0, 6)

        let vineRaw = 2.0 * vineCorrect - 1.0 * vineNonTarget - 0.3 * vineEarly
        let vineScore = clamp(vineRaw, 0, 32)

        let hStar = starHeight(time: starT)
        let hPetal = floorH + (1 - floorH) * CGFloat(petalScore / 6.0)
        let hVine = floorH + (1 - floorH) * CGFloat(vineScore / 32.0)

        let bandStarTop = starHeight(time: tBandLow)   // 30s
        let bandStarBot = starHeight(time: tBandHigh)  // 45s

        let bandPetalTop = floorH + (1 - floorH) * CGFloat(5.0 / 6.0)
        let bandPetalBot = floorH + (1 - floorH) * CGFloat(3.0 / 6.0)

        let bandVineTop = floorH + (1 - floorH) * CGFloat(27.0 / 32.0)
        let bandVineBot = floorH + (1 - floorH) * CGFloat(18.0 / 32.0)

        let bandShift: CGFloat = 0.03
        let bandStarTopAdj = max(0, bandStarTop - bandShift)
        let bandStarBotAdj = max(0, bandStarBot - bandShift)
        let bandVineTopAdj = max(0, bandVineTop - bandShift)
        let bandVineBotAdj = max(0, bandVineBot - bandShift)

        VStack(spacing: 14) {
            LongBarChart(
                values: [hStar, hPetal, hVine],
                bandTops: [bandStarTopAdj, bandPetalTop, bandVineTopAdj],
                bandBots: [bandStarBotAdj, bandPetalBot, bandVineBotAdj],
                xLabels: ["Attention", "Short-term Memory", "Cognitive Flexibility"],
                yAxisLabel: "Reference band"
            )
            .frame(height: 360)
            .frame(maxWidth: 920)

            VStack(alignment: .leading, spacing: 18) {
                Text("Use the reference band to compare day-to-day variation.")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.50))

                ReportCopyBlocks(
                    starsTimeS: starT,
                    petalNonTargetTaps: Int(petalNonTarget),
                    vineCorrect: Int(vineCorrect),
                    vineNonTarget: Int(vineNonTarget),
                    vineEarly: Int(vineEarly)
                )
            }
            .frame(width: 818, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .center)

            Text("This report is for reflection only and is not medical advice or a diagnosis. If you're concerned, please consult a professional.")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.45))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 26)
                .padding(.bottom, 10)
        }
        .padding(.horizontal, 26)
    }

    // MARK: - time -> height
    private func starHeight(time tOpt: Double?) -> CGFloat {
        guard let t = tOpt else { return floorH }

        // 20s 
        if t <= tFull { return 1.0 }

        // 20..45
        let hAtBandHigh: CGFloat = 0.85
        if t <= tBandHigh {
            let u = (t - tFull) / max(1e-6, (tBandHigh - tFull))
            return 1.0 + (hAtBandHigh - 1.0) * CGFloat(min(max(u, 0), 1))
        }

        // >45
        let u = (t - tBandHigh) / max(1e-6, (tFloor - tBandHigh))
        let h = hAtBandHigh + (floorH - hAtBandHigh) * CGFloat(min(max(u, 0), 1))
        return max(floorH, min(1.0, h))
    }

    private func clamp(_ v: Double, _ lo: Double, _ hi: Double) -> Double {
        min(max(v, lo), hi)
    }
}

// MARK: - Chart view
private struct ReportCopyBlocks: View {
    let starsTimeS: Double?
    let petalNonTargetTaps: Int
    let vineCorrect: Int
    let vineNonTarget: Int
    let vineEarly: Int

    private var petalScore: Int {
        max(0, 6 - petalNonTargetTaps)
    }

    private var vineScore: Double {
        let raw = 2.0 * Double(vineCorrect) - 1.0 * Double(vineNonTarget) - 0.3 * Double(vineEarly)
        return min(max(raw, 0.0), 32.0)
    }

    private enum Bucket { case good, normal, support }

    private var attentionBucket: Bucket {
        guard let t = starsTimeS else { return .normal }
        if t <= 30 { return .good }
        if t <= 45 { return .normal }
        return .support
    }

    private var memoryBucket: Bucket {
        if petalScore >= 5 { return .good }
        if petalScore >= 3 { return .normal }
        return .support
    }

    private var flexBucket: Bucket {
        if vineScore >= 28 { return .good }
        if vineScore >= 18 { return .normal }
        return .support
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            SectionCard(title: "Attention", content: attentionCopy)
            SectionCard(title: "Short-term Memory", content: memoryCopy)
            SectionCard(title: "Cognitive Flexibility", content: flexCopy)
            SectionCard(title: "Summary", content: summaryCopy)
        }
        .padding(.top, 6)
    }

    // MARK: - Copy builders

    private var attentionCopy: [String] {
        switch attentionBucket {
        case .good:
            return [
                "Takeaway: Today, your parent can stay focused more easily.",
                "You may notice: One reminder is enough to start, with fewer call-backs.",
                "This often means: Fewer distractions and more mental energy right now.",
                "If the room suddenly gets noisy: focus may break, and they may lose the thread.",
                "What you can do: One task at a time. Use short cues (e.g., \"Look here\"). Pause for two seconds after speaking."
            ]
        case .normal:
            return [
                "Takeaway: Focus may drift briefly, but returns with a gentle cue.",
                "You may notice: They scan the room, then come back; after an interruption, they need a moment to realign.",
                "This often means: Attention is working in a \"scan and return\" rhythm, not a lack of effort.",
                "If you push too fast: it can feel more scattered, because the brain needs time to come back.",
                "What you can do: One step at a time. Pause two seconds between lines. Lower background noise. Softly say, \"Let’s do this step first.\""
            ]
        case .support:
            return [
                "Takeaway: Today, the environment pulls attention away more easily.",
                "You may notice: Eyes move from thing to thing; steps get interrupted quickly.",
                "This often means: Fatigue, tension, or too much input is using up attention resources.",
                "If you speed up or get louder: they may feel more tense, and focus returns even slower.",
                "What you can do: Break it into the smallest step (e.g., \"Sit down\", \"Pick up the cup\"). Pause 3–5 seconds between steps. Move to a quieter spot if needed."
            ]
        }
    }

    private var memoryCopy: [String] {
        switch memoryBucket {
        case .good:
            return [
                "Takeaway: Short-term memory is steadier today.",
                "You may notice: After you say the steps once, they can keep going with fewer check-ins.",
                "This often means: Working memory has enough room to hold information for a bit.",
                "If you give too much at once: details can still drop, because capacity is limited.",
                "What you can do: Give at most 2–3 instructions at once. Confirm after each step. Keep frequently used items in a consistent place."
            ]
        case .normal:
            return [
                "Takeaway: Short-term memory varies, and occasional re-cueing helps.",
                "You may notice: A detail slips, but they recover after you repeat the key word.",
                "This often means: When input piles up, working memory lets go more easily. Slower feels steadier.",
                "If you rapid-fire reminders: the messages crowd each other out.",
                "What you can do: Say one line, then pause two seconds. Repeat only the keyword (e.g., \"cup\", \"water\"). Write it down or point to it. Keep choices to two steps or fewer."
            ]
        case .support:
            return [
                "Takeaway: Today, recent details slip more easily and need external cues.",
                "You may notice: More taps on non-targets, or forgetting the next step mid-way.",
                "This often means: Working memory is overloaded, and distractions take the space.",
                "If you press with \"How did you forget again?\": stress rises, and memory gets less stable.",
                "What you can do: Make cues visible (notes, checklist, pointing). Ask them to repeat the keyword. Break tasks smaller and slower. Demonstrate the first step if needed."
            ]
        }
    }

    private var flexCopy: [String] {
        switch flexBucket {
        case .good:
            return [
                "Takeaway: Today, they adapt to rule changes more quickly.",
                "You may notice: When the cue changes, they switch methods with less sticking to the old pattern.",
                "This often means: Switching cost is lower, so actions feel smoother and emotions steadier.",
                "If changes come too often: even in a good state, they may need a clearer next step.",
                "What you can do: State the new rule in one sentence, then give the next step. Keep your pace steady. Change one thing at a time."
            ]
        case .normal:
            return [
                "Takeaway: They pause before switching. That pause is realignment.",
                "You may notice: A brief stop to think, then a steadier move forward.",
                "This often means: They need confirmation time, not that they are \"slow.\"",
                "If you interrupt right away: mismatches and re-dos become more likely.",
                "What you can do: Say the rule clearly, then guide step by step. Give 2–3 seconds when they pause. Reduce last-minute plan changes."
            ]
        case .support:
            return [
                "Takeaway: Today, rule switching is more likely to misalign.",
                "You may notice: The old sequence carries over, or they overshoot during the shift.",
                "This often means: Too much change or too much noise makes \"what’s next\" harder to judge.",
                "If you demand they \"keep up\": load stacks up, and mismatches increase.",
                "What you can do: Reduce how often things change. Say, \"We restart from here.\" Point to the next step or write it down. Move one small goal at a time."
            ]
        }
    }

    private var summaryCopy: [String] {

        let overall: String = {
            let goodCount = [attentionBucket, memoryBucket, flexBucket].filter { $0 == .good }.count
            let supportCount = [attentionBucket, memoryBucket, flexBucket].filter { $0 == .support }.count
            if goodCount >= 2 { return "Today feels like a lighter day." }
            if supportCount >= 2 { return "Today feels like a day for pauses." }
            return "Today feels steady." 
        }()

        let weakest: String = {
            if attentionBucket == .support { return "Attention" }
            if memoryBucket == .support { return "Short-term Memory" }
            if flexBucket == .support { return "Cognitive Flexibility" }
            // If none are support, prefer normal
            if attentionBucket == .normal { return "Attention" }
            if memoryBucket == .normal { return "Short-term Memory" }
            if flexBucket == .normal { return "Cognitive Flexibility" }
            return "Pace"
        }()

        let oneThing: String = {
            switch weakest {
            case "Attention": return "If you do one thing: make it smaller, one step per line, with a few seconds of space."
            case "Short-term Memory": return "If you do one thing: make the key info visible—write it down or point to it."
            case "Cognitive Flexibility": return "If you do one thing: state the new rule first, then the next step. Avoid back-to-back switches."
            default: return "If you do one thing: slow the pace and steady this one small step."
            }
        }()

        return [
            overall,
            "Across the three dimensions, the one that may need more care today is: \(weakest).",
            "When your parent can’t keep up, speeding up rarely helps. Shorter lines, smaller steps, and a slower pace often work better.",
            oneThing
        ]
    }
}

private struct SectionCard: View {
    let title: String
    let content: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.78))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(content.enumerated()), id: \.offset) { _, line in
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.55))
                            .padding(.top, 1)

                        Text(line)
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.black.opacity(0.68))
                            .lineSpacing(7)
                    }
                }
            }
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.35))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
    }
}

private struct BarWithBand: View {
    let title: String
    let subtitle: String
    let height01: CGFloat
    let bandTop01: CGFloat
    let bandBot01: CGFloat
    let fill: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.06))

                GeometryReader { geo in
                    let H = geo.size.height
                    let bandTopY = (1 - bandTop01) * H
                    let bandBotY = (1 - bandBot01) * H
                    let bandH = max(6, bandBotY - bandTopY)

                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.black.opacity(0.10))
                        .frame(height: bandH)
                        .position(x: geo.size.width/2, y: bandTopY + bandH/2)
                        .allowsHitTesting(false)

                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(fill)
                        .frame(height: max(10, height01 * H))
                        .position(x: geo.size.width/2, y: H - max(10, height01 * H)/2)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: 86, height: 240)

            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.72))
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.48))
            }
        }
    }
}

private struct LongBarChart: View {
    let values: [CGFloat]      // 0..1
    let bandTops: [CGFloat]    // 0..1 (higher)
    let bandBots: [CGFloat]    // 0..1 (lower)
    let xLabels: [String]
    let yAxisLabel: String

    var body: some View {
        GeometryReader { geo in
            longChartContent(geo: geo)
        }
    }

    private func longChartContent(geo: GeometryProxy) -> some View {
        let W = geo.size.width
        let H = geo.size.height

        // Plot area margins
        let left: CGFloat = 78
        let right: CGFloat = 24
        let top: CGFloat = 18
        let bottom: CGFloat = 64

        let plotW = max(0, W - left - right)
        let plotH = max(0, H - top - bottom)

        // 3 bars
        let n = min(values.count, 3)
        let barW: CGFloat = 54 // narrower

        let barSideInset: CGFloat = 70

        let barLeft = left + barSideInset
        let barPlotW = max(0, plotW - barSideInset * 2)

        let gap = n > 1 ? (barPlotW - CGFloat(n) * barW) / CGFloat(n - 1) : 0

        func xCenter(_ i: Int) -> CGFloat {
            barLeft + CGFloat(i) * (barW + gap) + barW / 2
        }
        func yFrom01(_ v01: CGFloat) -> CGFloat {
            top + (1 - v01) * plotH
        }
        func barHeight(_ v01: CGFloat) -> CGFloat {
            max(10, v01 * plotH)
        }

        let barFill = Color(red: 225.0/255.0, green: 174.0/255.0, blue: 141.0/255.0)
        let bandFill = Color(red: 252.0/255.0, green: 218.0/255.0, blue: 196.0/255.0)



        return ZStack {
            // Axes
            Path { p in
                p.move(to: CGPoint(x: left, y: top))
                p.addLine(to: CGPoint(x: left, y: top + plotH))
                p.move(to: CGPoint(x: left, y: top + plotH))
                p.addLine(to: CGPoint(x: left + plotW, y: top + plotH))
            }
            .stroke(Color.black.opacity(0.22), lineWidth: 1)

            Text(yAxisLabel)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.55))
                .position(x: left / 2, y: top + 38)

            // Bars
            ForEach(0..<n, id: \.self) { i in
                let h = barHeight(values[i])
                TopRoundedBarShape(radius: 8)
                    .fill(barFill)
                    .frame(width: barW, height: h)
                    .position(x: xCenter(i), y: top + plotH - h/2)
            }

            ForEach(0..<n, id: \.self) { i in
                let topY = yFrom01(bandTops[i])
                let botY = yFrom01(bandBots[i])
                let bandH = max(6, botY - topY)

                Rectangle()
                    .fill(bandFill.opacity(0.55))
                    .frame(width: barW, height: bandH)
                    .position(x: xCenter(i), y: topY + bandH / 2)
            }

            // 0 -> 1
            Path { p in
                guard n == 3 else { return }

                let x0r = xCenter(0) + barW / 2
                let x1l = xCenter(1) - barW / 2

                let y0t = yFrom01(bandTops[0])
                let y1t = yFrom01(bandTops[1])
                let y0b = yFrom01(bandBots[0])
                let y1b = yFrom01(bandBots[1])

                p.move(to: CGPoint(x: x0r, y: y0t))
                p.addLine(to: CGPoint(x: x1l, y: y1t))
                p.addLine(to: CGPoint(x: x1l, y: y1b))
                p.addLine(to: CGPoint(x: x0r, y: y0b))
                p.closeSubpath()
            }
            .fill(bandFill.opacity(0.55))

            // 1 -> 2
            Path { p in
                guard n == 3 else { return }

                let x1r = xCenter(1) + barW / 2
                let x2l = xCenter(2) - barW / 2

                let y1t = yFrom01(bandTops[1])
                let y2t = yFrom01(bandTops[2])
                let y1b = yFrom01(bandBots[1])
                let y2b = yFrom01(bandBots[2])

                p.move(to: CGPoint(x: x1r, y: y1t))
                p.addLine(to: CGPoint(x: x2l, y: y2t))
                p.addLine(to: CGPoint(x: x2l, y: y2b))
                p.addLine(to: CGPoint(x: x1r, y: y1b))
                p.closeSubpath()
            }
            .fill(bandFill.opacity(0.55))


            ForEach(0..<n, id: \.self) { i in
                Text(xLabels[i])
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.70))
                    .frame(width: barW + 26)
                    .position(x: xCenter(i), y: top + plotH + 34)
            }
        }
        .frame(width: W, height: H)
    }
}

private struct TopRoundedBarShape: Shape {
    var radius: CGFloat = 8

    func path(in rect: CGRect) -> Path {
        let r = min(radius, rect.width / 2, rect.height)
        var p = Path()

        // Start at bottom-left
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        // Up to top-left corner arc start
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        // Top-left arc
        p.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        // Top edge to top-right arc start
        p.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        // Top-right arc
        p.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        // Down to bottom-right
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        // Close along bottom
        p.closeSubpath()
        return p
    }
}
