import SwiftUI


struct ThirdInteractionView: View {
    let onClose: () -> Void
    let onBackToGarden: () -> Void

    @State private var vineLitBalls: Set<Int> = []
    @State private var vineFlashBalls: Set<Int> = []
    @State private var vineBreathSyncStart: Date = Date()
    @State private var didSetVineBreathSync = false

    private enum VineStage { case stageA, stageB, stageC1, stageC2, done }
    @State private var vineStage: VineStage = .stageA

    private let orderA: [Int] = [1, 2, 5, 7]
    private let orderB: [Int] = [7, 6, 4, 1]
    private let orderC1: [Int] = [1, 3, 5, 7]
    private let orderC2: [Int] = [6, 4, 3, 2]
    @State private var vineOrderStep: Int = 0
    @State private var vineGrayBalls: Set<Int> = []
    @State private var vineGrayWorkItems: [Int: DispatchWorkItem] = [:]

    // Input lock and completion guard for delayed clears/popups
    @State private var vineInputLocked = false
    @State private var vineIsCompletingStage = false

    @State private var showVinePoeticCard = true
    @State private var showVineInstructionCard = false
    @State private var vineCardOpacity: Double = 0.0

    @State private var showVineSequenceCard = false
    @State private var showVineReverseCard = false

    @State private var showVineFinalPlanCard = false

    @State private var showVineCongratsCard = false

    @State private var showVineThanksCard = false

    @State private var showHelpCard = false
    @State private var helpCardOpacity: Double = 0.0
    
    @State private var vineCorrectTapCount: Int = 0
    @State private var vineEarlyTapCount: Int = 0
    @State private var vineNonTargetTapCount: Int = 0
    
    @AppStorage("bgmOn") private var bgmOn: Bool = true
    
    private var activeOrder: [Int] {
        switch vineStage {
        case .stageA: return orderA
        case .stageB: return orderB
        case .stageC1: return orderC1
        case .stageC2: return orderC2
        case .done: return []
        }
    }
    private var shouldShowTopPill: Bool {
        !(showVinePoeticCard || showVineInstructionCard || showVineSequenceCard || showVineReverseCard || showVineFinalPlanCard || showVineCongratsCard || showVineThanksCard || showHelpCard)
        && !vineInputLocked
        && !vineIsCompletingStage
        && vineStage != .done
    }

    private var topPillText: String {
        switch vineStage {
        case .stageA:
            return "Follow the path in order\nBlue, Purple, Blue, Orange"
        case .stageB:
            return "Follow the path in reverse\nMoon, Flower, Flower, Moon"
        case .stageC1:
            return "First, follow the path in order\nBlue, ⭐️, ⭐️, Orange"
        case .stageC2:
            return "Then, follow the path in reverse\n🌼, 🌼, Orange, Purple"
        case .done:
            return ""
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let screenW = geo.size.width
            let screenH = geo.size.height

            let baseW: CGFloat = 4096
            let baseH: CGFloat = 2748

            let s = max(screenW / baseW, screenH / baseH)
            let xOff = (screenW - baseW * s) * 0.5
            let yOff = (screenH - baseH * s) * 0.5

            let mapX: (CGFloat) -> CGFloat = { xOff + $0 * s }
            let mapY: (CGFloat) -> CGFloat = { yOff + $0 * s }
            let mapW: (CGFloat) -> CGFloat = { $0 * s }
            let mapH: (CGFloat) -> CGFloat = { $0 * s }

            let dx: CGFloat = 711.92
            let dy: CGFloat = 514.31
            let dw: CGFloat = 3174.38
            let dh: CGFloat = 1887.19

            ZStack {
                Image("bg3_vine")
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenW, height: screenH)
                    .clipped()

                ZStack {
                    VineBallGlowView(
                        shape: VineBall_1(),
                        isOn: vineLitBalls.contains(1) || vineFlashBalls.contains(1),
                        flashOn: vineFlashBalls.contains(1),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_2(),
                        isOn: vineLitBalls.contains(2) || vineFlashBalls.contains(2),
                        flashOn: vineFlashBalls.contains(2),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_3(),
                        isOn: vineLitBalls.contains(3) || vineFlashBalls.contains(3),
                        flashOn: vineFlashBalls.contains(3),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_4(),
                        isOn: vineLitBalls.contains(4) || vineFlashBalls.contains(4),
                        flashOn: vineFlashBalls.contains(4),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_5(),
                        isOn: vineLitBalls.contains(5) || vineFlashBalls.contains(5),
                        flashOn: vineFlashBalls.contains(5),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_6(),
                        isOn: vineLitBalls.contains(6) || vineFlashBalls.contains(6),
                        flashOn: vineFlashBalls.contains(6),
                        breathSyncStart: vineBreathSyncStart
                    )
                    VineBallGlowView(
                        shape: VineBall_7(),
                        isOn: vineLitBalls.contains(7) || vineFlashBalls.contains(7),
                        flashOn: vineFlashBalls.contains(7),
                        breathSyncStart: vineBreathSyncStart
                    )

                    VineGlowDashOverlay()
                        .allowsHitTesting(false)

                    Group {
                        VineBall_1().fill(Color.white.opacity(0.03)).overlay(VineBall_1().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_2().fill(Color.white.opacity(0.03)).overlay(VineBall_2().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_3().fill(Color.white.opacity(0.03)).overlay(VineBall_3().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_4().fill(Color.white.opacity(0.03)).overlay(VineBall_4().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_5().fill(Color.white.opacity(0.03)).overlay(VineBall_5().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_6().fill(Color.white.opacity(0.03)).overlay(VineBall_6().stroke(Color.white.opacity(0.22), lineWidth: 2))
                        VineBall_7().fill(Color.white.opacity(0.03)).overlay(VineBall_7().stroke(Color.white.opacity(0.22), lineWidth: 2))
                    }
                    .allowsHitTesting(false)

                Group {
                    if vineGrayBalls.contains(1) { VineBall_1().fill(Color.black.opacity(0.58)).overlay(VineBall_1().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(2) { VineBall_2().fill(Color.black.opacity(0.58)).overlay(VineBall_2().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(3) { VineBall_3().fill(Color.black.opacity(0.58)).overlay(VineBall_3().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(4) { VineBall_4().fill(Color.black.opacity(0.58)).overlay(VineBall_4().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(5) { VineBall_5().fill(Color.black.opacity(0.58)).overlay(VineBall_5().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(6) { VineBall_6().fill(Color.black.opacity(0.58)).overlay(VineBall_6().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                    if vineGrayBalls.contains(7) { VineBall_7().fill(Color.black.opacity(0.58)).overlay(VineBall_7().stroke(Color.white.opacity(0.20), lineWidth: 2)) }
                }
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: 0.18), value: vineGrayBalls)



                    VineBallHitArea(shape: VineBall_1()) { vineBallTap(1) }
                    VineBallHitArea(shape: VineBall_2()) { vineBallTap(2) }
                    VineBallHitArea(shape: VineBall_3()) { vineBallTap(3) }
                    VineBallHitArea(shape: VineBall_4()) { vineBallTap(4) }
                    VineBallHitArea(shape: VineBall_5()) { vineBallTap(5) }
                    VineBallHitArea(shape: VineBall_6()) { vineBallTap(6) }
                    VineBallHitArea(shape: VineBall_7()) { vineBallTap(7) }
                }
                .allowsHitTesting(!(showVinePoeticCard || showVineInstructionCard || showVineSequenceCard || showVineReverseCard || showVineFinalPlanCard || vineInputLocked))
                .frame(width: mapW(dw), height: mapH(dh))
                .position(
                    x: mapX(dx + dw / 2),
                    y: mapY(dy + dh / 2)
                )


                if showVinePoeticCard {
                    VinePoeticIntroCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVinePoeticCard = false
                            showVineInstructionCard = true
                            vineCardOpacity = 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    vineCardOpacity = 1.0
                                }
                            }
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineInstructionCard {
                    VineInstructionCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVineInstructionCard = false
                            showVineSequenceCard = true
                            vineCardOpacity = 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    vineCardOpacity = 1.0
                                }
                            }
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineSequenceCard {
                    VineSequenceCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVineSequenceCard = false
                            vineInputLocked = false
                            vineStage = .stageA
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineReverseCard {
                    VineReverseCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVineReverseCard = false
                            vineStage = .stageB
                            vineInputLocked = false
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineFinalPlanCard {
                    VineFinalPlanCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVineFinalPlanCard = false
                            vineStage = .stageC1
                            vineInputLocked = false
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineCongratsCard {
                    VineCongratsCard {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            vineCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showVineCongratsCard = false

                            showVineThanksCard = true
                            vineCardOpacity = 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    vineCardOpacity = 1.0
                                }
                            }
                        }
                    }
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showVineThanksCard {
                    VineThanksCard(
                        onReplay: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                vineCardOpacity = 0.0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                showVineThanksCard = false

                                vineCorrectTapCount = 0
                                vineEarlyTapCount = 0
                                vineNonTargetTapCount = 0
                                clearAllFeedback()
                                vineOrderStep = 0
                                vineStage = .stageA
                                vineInputLocked = false
                                vineIsCompletingStage = false

                                vineLitBalls.removeAll()
                                vineFlashBalls.removeAll()
                                didSetVineBreathSync = false
                                vineBreathSyncStart = Date()

                                showVineSequenceCard = false
                                showVineReverseCard = false
                                showVineFinalPlanCard = false
                                showVineCongratsCard = false

                                showVinePoeticCard = true
                                showVineInstructionCard = false
                                vineCardOpacity = 0.0
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        vineCardOpacity = 1.0
                                    }
                                }
                            }
                        },
                        onBackToGarden: {
                            MindGardenMetricsStore.shared.recordVine(
                                correct: vineCorrectTapCount,
                                early: vineEarlyTapCount,
                                nonTarget: vineNonTargetTapCount
                            )
                            onBackToGarden()
                        }
                    )
                    .opacity(vineCardOpacity)
                    .transition(.opacity)
                    .zIndex(999)
                }

                if showHelpCard {
                    VineHelpCard {
                        withAnimation(.easeInOut(duration: 0.20)) {
                            helpCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                            showHelpCard = false
                        }
                    }
                    .opacity(helpCardOpacity)
                    .transition(.opacity)
                    .zIndex(1200)
                }

                VStack {
                    ZStack {
                        HStack {
                            ThirdGlassIconButton(
                                systemName: "chevron.left",
                                action: { onClose() }
                            )
                            .padding(.leading, 20)
                            .padding(.top, (geo.safeAreaInsets.top == 0 ? 44 : geo.safeAreaInsets.top) )

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
                            .padding(.trailing, 10)
                            .padding(.top, (geo.safeAreaInsets.top == 0 ? 44 : geo.safeAreaInsets.top))

                            ThirdGlassIconButton(
                                systemName: "questionmark",
                                action: {
                                    showHelpCard = true
                                    helpCardOpacity = 0.0
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            helpCardOpacity = 1.0
                                        }
                                    }
                                }
                            )
                            .padding(.trailing, 20)
                            .padding(.top, (geo.safeAreaInsets.top == 0 ? 44 : geo.safeAreaInsets.top) )
                        }

                        if shouldShowTopPill {
                            ThirdGlassPill(text: topPillText)
                                .padding(.top, (geo.safeAreaInsets.top == 0 ? 44 : geo.safeAreaInsets.top))
                        }
                    }

                    Spacer()
                }

            }
        }
        .ignoresSafeArea()
        .onAppear {
            vineCorrectTapCount = 0
            vineEarlyTapCount = 0
            vineNonTargetTapCount = 0
            if showVinePoeticCard {
                vineCardOpacity = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        vineCardOpacity = 1.0
                    }
                }
            }
        }
    }

    private func clearAllFeedback() {
        vineLitBalls.removeAll()
        vineFlashBalls.removeAll()

        vineGrayBalls.removeAll()
        vineGrayWorkItems.values.forEach { $0.cancel() }
        vineGrayWorkItems.removeAll()
    }

    private func vineBallTap(_ id: Int) {
        // Input lock: Prevent taps during completion delay or while locked
        if vineInputLocked || vineIsCompletingStage { return }
        // If no active stage, ignore
        let order = activeOrder
        if order.isEmpty { return }

        let targetSet = Set(order)

        if !targetSet.contains(id) {
            vineNonTargetTapCount += 1
            if let item = vineGrayWorkItems[id] {
                item.cancel(); vineGrayWorkItems[id] = nil
            }
            withAnimation(.easeInOut(duration: 0.18)) {
                vineGrayBalls.insert(id)
            }
            return
        }

        let expected: Int? = (vineOrderStep < order.count) ? order[vineOrderStep] : nil

        if let exp = expected, id == exp {
            vineCorrectTapCount += 1
            vineFlashBalls.insert(id)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                vineFlashBalls.remove(id)
            }

            vineLitBalls.insert(id)

            if !didSetVineBreathSync {
                vineBreathSyncStart = Date().addingTimeInterval(0.22)
                didSetVineBreathSync = true
            }

            vineOrderStep += 1

            if vineOrderStep >= order.count {
                if vineIsCompletingStage { return }
                vineIsCompletingStage = true

                vineInputLocked = true
                let stageAtFinish = vineStage

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    clearAllFeedback()
                    vineOrderStep = 0

                    switch stageAtFinish {
                    case .stageA:
                        showVineReverseCard = true
                        vineCardOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeInOut(duration: 0.25)) { vineCardOpacity = 1.0 }
                        }

                    case .stageB:
                        showVineFinalPlanCard = true
                        vineCardOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeInOut(duration: 0.25)) { vineCardOpacity = 1.0 }
                        }

                    case .stageC1:
                        vineStage = .stageC2
                        vineInputLocked = false

                    case .stageC2:
                        showVineCongratsCard = true
                        vineCardOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                vineCardOpacity = 1.0
                            }
                        }

                    case .done:
                        vineInputLocked = false
                    }

                    vineIsCompletingStage = false
                }
            }
            return
        }

        vineEarlyTapCount += 1
        if let item = vineGrayWorkItems[id] {
            item.cancel(); vineGrayWorkItems[id] = nil
        }
        withAnimation(.easeInOut(duration: 0.18)) {
            vineGrayBalls.insert(id)
        }
        let work = DispatchWorkItem {
            withAnimation(.easeInOut(duration: 0.18)) {
                vineGrayBalls.remove(id)
            }
            vineGrayWorkItems[id] = nil
        }
        vineGrayWorkItems[id] = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }
}

private struct VineBallHitArea<S: Shape>: View {
    let shape: S
    let onTap: () -> Void

    init(shape: S, onTap: @escaping () -> Void) {
        self.shape = shape
        self.onTap = onTap
    }

    var body: some View {
        GeometryReader { proxy in
            let p = shape.path(in: CGRect(origin: .zero, size: proxy.size))
            let hit = p.strokedPath(
                StrokeStyle(lineWidth: 46, lineCap: .round, lineJoin: .round)
            )

            Color.black.opacity(0.001)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(hit)
                .onTapGesture { onTap() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }
}


private struct VineGlowDashOverlay: View {
    @State private var breathe = false
    @State private var dashPhase: CGFloat = 0

    // rgb(222,157,115)
    private let c = Color(red: 222.0/255.0, green: 157.0/255.0, blue: 115.0/255.0)

    var body: some View {
        ZStack {
            VineGlowPaths_3176x1889()
                .stroke(
                    c.opacity(breathe ? 0.34 : 0.16),
                    style: StrokeStyle(lineWidth: breathe ? 26 : 18, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: breathe ? 18 : 12)
                .compositingGroup()
                .blendMode(.plusLighter)

            VineGlowPaths_3176x1889()
                .stroke(
                    c.opacity(breathe ? 0.58 : 0.26),
                    style: StrokeStyle(lineWidth: breathe ? 9 : 6, lineCap: .round, lineJoin: .round)
                )
                .blur(radius: breathe ? 10 : 6)
                .shadow(color: c.opacity(breathe ? 0.45 : 0.22), radius: breathe ? 18 : 10)
                .compositingGroup()
                .blendMode(.screen)

            VineGlowPaths_3176x1889()
                .stroke(
                    c.opacity(0.22),
                    style: StrokeStyle(
                        lineWidth: 2.0,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [10, 10],
                        dashPhase: dashPhase
                    )
                )
                .compositingGroup()
                .blendMode(.screen)
        }
        .onAppear {
            breathe = true

            dashPhase = 0
            withAnimation(.linear(duration: 4.2).repeatForever(autoreverses: false)) {
                dashPhase = -220
            }
        }
    }
}


private struct VineBallGlowView<S: Shape>: View {
    let shape: S
    let isOn: Bool
    let flashOn: Bool
    let breathSyncStart: Date

    @State private var rampAmt: Double = 0
    @State private var didInit = false

    // rgb(222,157,115)
    private let c = Color(red: 222.0/255.0, green: 157.0/255.0, blue: 115.0/255.0)

    var body: some View {
        GeometryReader { proxy in
            let rect = CGRect(origin: .zero, size: proxy.size)
            let path = shape.path(in: rect)
            let b = path.boundingRect

            let cx = (b.midX / max(rect.width, 1))
            let cy = (b.midY / max(rect.height, 1))
            let topY = (b.minY / max(rect.height, 1))
            let botY = (b.maxY / max(rect.height, 1))

            let centerP = UnitPoint(x: cx, y: cy)
            let topP = UnitPoint(x: cx, y: topY)
            let botP = UnitPoint(x: cx, y: botY)

            let baseR = max(b.width, b.height)
            let rCenter = max(160, baseR * 0.95)
            let rEdge = max(140, baseR * 0.85)

            let amt = isOn ? rampAmt : 0

            ZStack {
                ZStack {
                    Rectangle()
                        .fill(radial(center: centerP, endRadius: rCenter, amt: amt))
                        .mask(shape)

                    Rectangle()
                        .fill(radial(center: topP, endRadius: rEdge, amt: amt))
                        .mask(shape)

                    Rectangle()
                        .fill(radial(center: botP, endRadius: rEdge, amt: amt))
                        .mask(shape)
                }
                .blur(radius: lerp(14, 20, amt))
                .compositingGroup()
                .blendMode(.plusLighter)

                shape
                    .stroke(
                        c.opacity(0.24 * amt),
                        style: StrokeStyle(lineWidth: lerp(10, 16, amt), lineCap: .round, lineJoin: .round)
                    )
                    .blur(radius: lerp(10, 14, amt))
                    .shadow(color: c.opacity(0.30 * amt), radius: lerp(16, 22, amt))
                    .compositingGroup()
                    .blendMode(.screen)
            }
            .onAppear {
                guard !didInit else { return }
                didInit = true
                rampAmt = isOn ? 1 : 0
            }
            .onChange(of: isOn) { _, on in
                if on {
                    rampAmt = 0
                    withAnimation(.easeOut(duration: 0.9)) {
                        rampAmt = 1
                    }
                } else {
                    rampAmt = 0
                }
            }
            .onChange(of: flashOn) { _, on in
                if on, isOn {
                    rampAmt = 0
                    withAnimation(.easeOut(duration: 0.55)) {
                        rampAmt = 1
                    }
                }
            }
            .allowsHitTesting(false)
        }
    }

    private func radial(center: UnitPoint, endRadius: CGFloat, amt: Double) -> RadialGradient {
        RadialGradient(
            stops: [
                .init(color: c.opacity(0.28 * amt), location: 0.0),
                .init(color: c.opacity(0.12 * amt), location: 0.62),
                .init(color: c.opacity(0.0), location: 1.0)
            ],
            center: center,
            startRadius: 0,
            endRadius: endRadius
        )
    }

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * min(max(t, 0), 1)
    }
}

private struct VineBall_1: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path1(in: rect) } }
private struct VineBall_2: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path2(in: rect) } }
private struct VineBall_3: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path3(in: rect) } }
private struct VineBall_4: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path4(in: rect) } }
private struct VineBall_5: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path5(in: rect) } }
private struct VineBall_6: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path6(in: rect) } }
private struct VineBall_7: Shape { func path(in rect: CGRect) -> Path { VineBallPaths.path7(in: rect) } }

private enum VineBallPaths {
    static let svgW: CGFloat = 3176
    static let svgH: CGFloat = 1889

    static func p(_ x: CGFloat, _ y: CGFloat, in rect: CGRect) -> CGPoint {
        let sx = rect.width / svgW
        let sy = rect.height / svgH
        return CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
    }

    static func path1(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(704.076, 148.688))
        path.addCurve(to: pt(449.577, 50.1879), control1: pt(689.873, -4.83603), control2: pt(539.306, -41.5639))
        path.addCurve(to: pt(449.577, 159.188), control1: pt(427.586, 67.261), control2: pt(433.591, 127.783))
        path.addCurve(to: pt(460.077, 252.688), control1: pt(462.24, 198.787), control2: pt(464.681, 218.8))
        path.addCurve(to: pt(704.076, 148.688), control1: pt(590.184, 340.505), control2: pt(700.585, 246.467))
        path.closeSubpath()
        return path
    }

    static func path2(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(246.077, 338.188))
        path.addCurve(to: pt(255.077, 247.688), control1: pt(275.98, 285.233), control2: pt(282.087, 270.48))
        path.addCurve(to: pt(0.577451, 332.188), control1: pt(144.487, 153.568), control2: pt(13.6326, 218.386))
        path.addCurve(to: pt(223.077, 468.188), control1: pt(-3.47389, 484.533), control2: pt(152.459, 516.55))
        path.addCurve(to: pt(246.077, 338.188), control1: pt(226.773, 428.514), control2: pt(228.494, 398.917))
        path.closeSubpath()
        return path
    }

    static func path3(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(422.077, 945.688))
        path.addCurve(to: pt(268.577, 774.688), control1: pt(427.469, 881.497), control2: pt(339.089, 780.696))
        path.addCurve(to: pt(188.077, 1026.19), control1: pt(213.059, 766.092), control2: pt(52.6086, 884.729))
        path.addCurve(to: pt(422.077, 945.688), control1: pt(295.647, 1099.89), control2: pt(390.757, 1040.23))
        path.closeSubpath()
        return path
    }

    static func path4(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(1530.58, 567.688))
        path.addCurve(to: pt(1401.58, 527.188), control1: pt(1471.61, 537.58), control2: pt(1443.03, 528.185))
        path.addCurve(to: pt(1581.08, 319.688), control1: pt(1343.06, 374.551), control2: pt(1480.81, 280.759))
        path.addCurve(to: pt(1595.58, 585.188), control1: pt(1682.17, 359.326), control2: pt(1719.64, 495.414))
        path.addCurve(to: pt(1530.58, 567.688), control1: pt(1574.74, 586.314), control2: pt(1560.87, 583.115))
        path.closeSubpath()
        return path
    }

    static func path5(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(1763.58, 871.688))
        path.addCurve(to: pt(1583.58, 791.188), control1: pt(1682.44, 864.936), control2: pt(1645.66, 851.296))
        path.addCurve(to: pt(1595.58, 1064.69), control1: pt(1471.99, 821.174), control2: pt(1441.36, 1019.23))
        path.addCurve(to: pt(1763.58, 871.688), control1: pt(1653.76, 1083.87), control2: pt(1812.86, 1038.7))
        path.closeSubpath()
        return path
    }

    static func path6(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(2095.08, 1437.69))
        path.addCurve(to: pt(2019.58, 1360.19), control1: pt(2053.45, 1388.77), control2: pt(2037.77, 1366.51))
        path.addCurve(to: pt(1945.08, 1623.19), control1: pt(1859.96, 1361.41), control2: pt(1840.86, 1564.33))
        path.addCurve(to: pt(2161.58, 1494.69), control1: pt(2009.29, 1671.4), control2: pt(2162.63, 1634.55))
        path.addCurve(to: pt(2095.08, 1437.69), control1: pt(2135.68, 1482.24), control2: pt(2121.1, 1466.35))
        path.closeSubpath()
        return path
    }

    static func path7(in rect: CGRect) -> Path {
        var path = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { p(x, y, in: rect) }
        path.move(to: pt(3039.08, 1650.69))
        path.addCurve(to: pt(2936.58, 1637.69), control1: pt(2991.57, 1639.1), control2: pt(2968.13, 1635.39))
        path.addCurve(to: pt(3034.08, 1887.69), control1: pt(2836.32, 1714.07), control2: pt(2893.37, 1888.8))
        path.addCurve(to: pt(3135.58, 1650.69), control1: pt(3135.78, 1885.98), control2: pt(3230.76, 1748.78))
        path.addCurve(to: pt(3039.08, 1650.69), control1: pt(3091.97, 1656.89), control2: pt(3071.97, 1655.71))
        path.closeSubpath()
        return path
    }
}

private struct VineGlowPaths_3176x1889: Shape {
    func path(in rect: CGRect) -> Path {
        let svgW: CGFloat = 3176
        let svgH: CGFloat = 1889

        let sx = rect.width / svgW
        let sy = rect.height / svgH

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + x * sx,
                y: rect.minY + y * sy
            )
        }

        var path = Path()

        // 1)
        path.move(to: p(704.076, 148.688))
        path.addCurve(to: p(449.577, 50.1879), control1: p(689.873, -4.83603), control2: p(539.306, -41.5639))
        path.addCurve(to: p(449.577, 159.188), control1: p(427.586, 67.261), control2: p(433.591, 127.783))
        path.addCurve(to: p(460.077, 252.688), control1: p(462.24, 198.787), control2: p(464.681, 218.8))
        path.addCurve(to: p(704.076, 148.688), control1: p(590.184, 340.505), control2: p(700.585, 246.467))

        // 2)
        path.move(to: p(246.077, 338.188))
        path.addCurve(to: p(255.077, 247.688), control1: p(275.98, 285.233), control2: p(282.087, 270.48))
        path.addCurve(to: p(0.577451, 332.188), control1: p(144.487, 153.568), control2: p(13.6326, 218.386))
        path.addCurve(to: p(223.077, 468.188), control1: p(-3.47389, 484.533), control2: p(152.459, 516.55))
        path.addCurve(to: p(246.077, 338.188), control1: p(226.773, 428.514), control2: p(228.494, 398.917))

        // 3)
        path.move(to: p(422.077, 945.688))
        path.addCurve(to: p(268.577, 774.688), control1: p(427.469, 881.497), control2: p(339.089, 780.696))
        path.addCurve(to: p(188.077, 1026.19), control1: p(213.059, 766.092), control2: p(52.6086, 884.729))
        path.addCurve(to: p(422.077, 945.688), control1: p(295.647, 1099.89), control2: p(390.757, 1040.23))

        // 4)
        path.move(to: p(1530.58, 567.688))
        path.addCurve(to: p(1401.58, 527.188), control1: p(1471.61, 537.58), control2: p(1443.03, 528.185))
        path.addCurve(to: p(1581.08, 319.688), control1: p(1343.06, 374.551), control2: p(1480.81, 280.759))
        path.addCurve(to: p(1595.58, 585.188), control1: p(1682.17, 359.326), control2: p(1719.64, 495.414))
        path.addCurve(to: p(1530.58, 567.688), control1: p(1574.74, 586.314), control2: p(1560.87, 583.115))

        // 5)
        path.move(to: p(1763.58, 871.688))
        path.addCurve(to: p(1583.58, 791.188), control1: p(1682.44, 864.936), control2: p(1645.66, 851.296))
        path.addCurve(to: p(1595.58, 1064.69), control1: p(1471.99, 821.174), control2: p(1441.36, 1019.23))
        path.addCurve(to: p(1763.58, 871.688), control1: p(1653.76, 1083.87), control2: p(1812.86, 1038.7))

        // 6)
        path.move(to: p(2095.08, 1437.69))
        path.addCurve(to: p(2019.58, 1360.19), control1: p(2053.45, 1388.77), control2: p(2037.77, 1366.51))
        path.addCurve(to: p(1945.08, 1623.19), control1: p(1859.96, 1361.41), control2: p(1840.86, 1564.33))
        path.addCurve(to: p(2161.58, 1494.69), control1: p(2009.29, 1671.4), control2: p(2162.63, 1634.55))
        path.addCurve(to: p(2095.08, 1437.69), control1: p(2135.68, 1482.24), control2: p(2121.1, 1466.35))

        // 7)
        path.move(to: p(3039.08, 1650.69))
        path.addCurve(to: p(2936.58, 1637.69), control1: p(2991.57, 1639.1), control2: p(2968.13, 1635.39))
        path.addCurve(to: p(3034.08, 1887.69), control1: p(2836.32, 1714.07), control2: p(2893.37, 1888.8))
        path.addCurve(to: p(3135.58, 1650.69), control1: p(3135.78, 1885.98), control2: p(3230.76, 1748.78))
        path.addCurve(to: p(3039.08, 1650.69), control1: p(3091.97, 1656.89), control2: p(3071.97, 1655.71))

        return path
    }
}





private struct VinePoeticIntroCard: View {
    let onNext: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 24) {
                        Text("🌿")
                            .font(.system(size: 34))
                            .padding(.bottom, -6)

                        VStack(spacing: 12) {
                            Text("Memory can twist like vines")
                            Text("It bends around what blocks it,\nlinking what fell apart")
                            Text("So does thinking.\nGo slower, and you still arrive")
                        }
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(Color.white.opacity(0.90))
                        .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)
                    }

                    Spacer()

                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}

private struct VineInstructionCard: View {
    let onStart: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 28) {
                        Text("Along the vine path")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Text("Tap the nodes in the order shown.")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Text("Each tap makes the path a little clearer.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)
                            .padding(.top, 10)
                    }

                    Spacer()

                    Button(action: onStart) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: - Soft-edge solid card background
private struct SoftEdgeSolidCardBackgroundVine: View {
    let cornerRadius: CGFloat
    let feather: CGFloat
    let featherBlur: CGFloat
    let fill: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            shape.fill(fill)

            shape
                .inset(by: max(0, feather - 4))
                .fill(fill)
        }
        .compositingGroup()
        .mask(
            shape
                .fill(Color.white)
                .blur(radius: featherBlur)
        )
        .shadow(color: Color.black.opacity(0.20), radius: 22, x: 0, y: 12)
    }
}

private struct VineSequenceCard: View {
    let onStart: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    private let blue = Color(red: 0.45, green: 0.70, blue: 1.00)
    private let purple = Color(red: 0.74, green: 0.55, blue: 0.98)
    private let orange = Color(red: 0.98, green: 0.64, blue: 0.32)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 28) {
                        Text("Now, follow the path in order")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Text("Tap in this order: Blue, Purple, Blue, Orange")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        HStack(spacing: 12) {
                            Circle().fill(blue).frame(width: 20, height: 20)
                            Circle().fill(purple).frame(width: 20, height: 20)
                            Circle().fill(blue).frame(width: 20, height: 20)
                            Circle().fill(orange).frame(width: 20, height: 20)
                        }
                        .padding(.top, 6)
                    }

                    Spacer()

                    Button(action: onStart) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}


private struct VineReverseCard: View {
    let onStart: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 28) {
                        Text("Now, follow the path in reverse")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Text("Tap in this order: Moon, Flower, Flower, Moon")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        HStack(spacing: 12) {
                            Text("🌙")
                            Text("🌼")
                            Text("🌼")
                            Text("🌙")
                        }
                        .font(.system(size: 26))
                        .padding(.top, 4)
                    }

                    Spacer()

                    Button(action: onStart) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}


private struct VineFinalPlanCard: View {
    let onStart: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    private let blue = Color(red: 0.45, green: 0.70, blue: 1.00)
    private let purple = Color(red: 0.74, green: 0.55, blue: 0.98)
    private let orange = Color(red: 0.98, green: 0.64, blue: 0.32)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 18) {
                        Text("Now, go in order, then in reverse")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        VStack(spacing: 10) {
                            Text("Blue, ⭐️, ⭐️, Orange")
                            Text("🌼, 🌼, Orange, Purple")
                        }
                        .font(.system(size: 18, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.90))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        VStack(spacing: 10) {
                            HStack(spacing: 14) {
                                Circle().fill(blue).frame(width: 20, height: 20)
                                Text("⭐️").font(.system(size: 22))
                                Text("⭐️").font(.system(size: 22))
                                Circle().fill(orange).frame(width: 20, height: 20)
                            }

                            HStack(spacing: 14) {
                                Text("🌼").font(.system(size: 22))
                                Text("🌼").font(.system(size: 22))
                                Circle().fill(orange).frame(width: 20, height: 20)
                                Circle().fill(purple).frame(width: 20, height: 20)
                            }
                        }
                        .padding(.top, 2)
                    }

                    Spacer()

                    Button(action: onStart) {
                        Text("Start")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}



private struct ThirdGlassIconButton: View {
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

private struct VineHelpCard: View {
    let onDismiss: () -> Void

    // #9EC09D (158,192,157)
    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 18) {
                    VStack(spacing: 24) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.9))

                        VStack(spacing: 12) {
                            Text("About this activity")
                                .font(.title3.bold())

                            Text("A small exercise for Cognitive Flexibility.\nWhen cues change,\ntry adjusting your pace and direction.")

                            Text("It helps you practice switching\nand returning to the present.")
                                .foregroundStyle(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(.white)
                    }

                    Button(action: onDismiss) {
                        Text("Got it.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .padding(.top, 18)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 48)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}

private struct ThirdGlassPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.white.opacity(0.92))
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(Capsule(style: .continuous).fill(Color.black.opacity(0.18)))
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1.4)
            )
            .shadow(color: Color.black.opacity(0.32), radius: 12, x: 0, y: 5)
            .accessibilityLabel(text.replacingOccurrences(of: "\n", with: " "))
    }
}





private struct VineCongratsCard: View {
    let onClose: () -> Void

    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 22) {
                        Text("You tapped every node")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Text("Vines twist, but you don’t need to rush")
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.90))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)
                    }

                    Spacer()

                    Button(action: onClose) {
                        Text("Got it.")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.95))
                            .padding(.horizontal, 34)
                            .padding(.vertical, 14)
                            .background {
                                Capsule(style: .continuous)
                                    .fill(accent.opacity(0.75))
                            }
                    }
                    .buttonStyle(.plain)
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}

private struct VineThanksCard: View {
    let onReplay: () -> Void
    let onBackToGarden: () -> Void

    private let accent = Color(red: 158.0/255.0, green: 192.0/255.0, blue: 157.0/255.0)

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 18) {
                        Text("🌱")
                            .font(.system(size: 34))
                            .padding(.bottom, -6)

                        Text("The vines thank your return gaze")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Color.clear.frame(height: 18)

                        Text("Cognitive Flexibility is like vines turning\nit may pause, then continue\neven if you move slower through change, you still arrive")
                            .font(.system(size: 17, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.86))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Color.clear.frame(height: 26)

                        HStack(spacing: 16) {
                            Button(action: onReplay) {
                                Text("Replay")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.92))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background {
                                        Capsule(style: .continuous)
                                            .fill(Color.white.opacity(0.10))
                                    }
                                    .overlay {
                                        Capsule(style: .continuous)
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                                    }
                            }
                            .buttonStyle(.plain)

                            Button(action: onBackToGarden) {
                                Text("Back to garden")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(Color.white.opacity(0.92))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background {
                                        Capsule(style: .continuous)
                                            .fill(Color.white.opacity(0.10))
                                    }
                                    .overlay {
                                        Capsule(style: .continuous)
                                            .stroke(Color.white.opacity(0.35), lineWidth: 1.2)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 48)
                .frame(width: cardW, height: 495)
                .background {
                    SoftEdgeSolidCardBackgroundVine(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: accent
                    )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                }
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
            }
            .ignoresSafeArea()
        }
    }
}
