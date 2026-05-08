import SwiftUI

struct SecondInteractionView: View {
    let onClose: () -> Void
    let onFinishedReturnToGarden: () -> Void
    private let designW: CGFloat = 2160
    private let designH: CGFloat = 1440

    @State private var bgA: String = "bg2_petal_triplet"
    @State private var bgB: String = "bg2_petal_triplet"
    @State private var showB: Bool = false

    @State private var showIntroCard = false
    @State private var introCardOpacity: Double = 0.0

    @State private var showHelpCard = false
    @State private var helpCardOpacity: Double = 0.0
    @State private var introDismissed = false
    
    @AppStorage("bgmOn") private var bgmOn: Bool = true
    
    @State private var glowVisible = false

    @State private var showRecallCard = false
    @State private var recallCardOpacity: Double = 0.0
    @State private var showResultCard = false
    @State private var resultCardOpacity: Double = 0.0
    @State private var didScheduleResultCard = false
    @State private var showCongratsCard = false
    @State private var congratsCardOpacity: Double = 0.0
    @State private var recallMode = false
    @State private var recalledPetals: Set<Int> = []
    
    @State private var petalTargetTapCount: Int = 0
    @State private var petalNonTargetTapCount: Int = 0
    
    @State private var halfFlowerTappedPetals: Set<Int> = []
    @State private var halfFlowerLitPetals: Set<Int> = []
    @State private var halfFlowerFlashPetals: Set<Int> = []
    @State private var halfFlowerShadowPetals: Set<Int> = []

    @State private var halfFlowerBreathSyncStart: Date = Date()
    @State private var didSetHalfFlowerBreathSync = false

    @State private var choiceTask: Task<Void, Never>? = nil

    @State private var choiceStep: Int = 0
    @State private var choiceOpacity: Double = 0.0
    @State private var didScheduleChoices = false

    @State private var nightChoice: String? = nil
    @State private var soundChoice: String? = nil

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let screenW = geo.size.width
                let screenH = geo.size.height

                let s = max(screenW / designW, screenH / designH)
                let xOff = (screenW - designW * s) * 0.5
                let yOff = (screenH - designH * s) * 0.5

                let mapX: (CGFloat) -> CGFloat = { x in xOff + x * s }
                let mapY: (CGFloat) -> CGFloat = { y in yOff + y * s }
                let mapW: (CGFloat) -> CGFloat = { w in w * s }
                let mapH: (CGFloat) -> CGFloat = { h in h * s }

                ZStack {
                    Image(bgA)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenW, height: screenH)
                        .clipped()
                        .opacity(showB ? 0 : 1)

                    Image(bgB)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenW, height: screenH)
                        .clipped()
                        .opacity(showB ? 1 : 0)

                    if glowVisible {
                        let r1x: CGFloat = 674.5
                        let r1y: CGFloat = 546.74
                        let r1w: CGFloat = 317
                        let r1h: CGFloat = 200.25
                        GlowRegionView(shape: PetalGlowArea_319x202(), enabled: true)
                            .frame(width: mapW(r1w), height: mapH(r1h))
                            .position(x: mapX(r1x + r1w/2), y: mapY(r1y + r1h/2))

                        let r2x: CGFloat = 980.4
                        let r2y: CGFloat = 740
                        let r2w: CGFloat = 198.1
                        let r2h: CGFloat = 279
                        GlowRegionView(shape: PetalGlowArea_200x281(), enabled: true)
                            .frame(width: mapW(r2w), height: mapH(r2h))
                            .position(x: mapX(r2x + r2w/2), y: mapY(r2y + r2h/2))

                        let r3x: CGFloat = 1122.5
                        let r3y: CGFloat = 356.18
                        let r3w: CGFloat = 246.81
                        let r3h: CGFloat = 257.82
                        GlowRegionView(shape: PetalGlowArea_249x259(), enabled: true)
                            .frame(width: mapW(r3w), height: mapH(r3h))
                            .position(x: mapX(r3x + r3w/2), y: mapY(r3y + r3h/2))
                    }

                    if currentBackgroundName == "bg2_half_flower" {
                        let baseW: CGFloat = 2496
                        let baseH: CGFloat = 1664

                        let s2 = max(screenW / baseW, screenH / baseH)
                        let xOff2 = (screenW - baseW * s2) * 0.5
                        let yOff2 = (screenH - baseH * s2) * 0.5

                        let dx: CGFloat = 783
                        let dy: CGFloat = 329.5
                        let dw: CGFloat = 936
                        let dh: CGFloat = 849

                        ZStack {
                            Group {
                                if halfFlowerShadowPetals.contains(1) { HalfFlowerRegion_1().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(2) { HalfFlowerRegion_2().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(3) { HalfFlowerRegion_3().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(4) { HalfFlowerRegion_4().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(5) { HalfFlowerRegion_5().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(6) { HalfFlowerRegion_6().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(7) { HalfFlowerRegion_7().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                                if halfFlowerShadowPetals.contains(8) { HalfFlowerRegion_8().fill(Color.black.opacity(0.35)).blur(radius: 1.0) }
                            }
                            .compositingGroup()
                            .blendMode(.multiply)
                            .allowsHitTesting(false)

                            if halfFlowerLitPetals.contains(1) {
                                GlowRegionView(shape: HalfFlowerRegion_1(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(1), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(2) {
                                GlowRegionView(shape: HalfFlowerRegion_2(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(2), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(3) {
                                GlowRegionView(shape: HalfFlowerRegion_3(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(3), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(4) {
                                GlowRegionView(shape: HalfFlowerRegion_4(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(4), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(5) {
                                GlowRegionView(shape: HalfFlowerRegion_5(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(5), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(6) {
                                GlowRegionView(shape: HalfFlowerRegion_6(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(6), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(7) {
                                GlowRegionView(shape: HalfFlowerRegion_7(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(7), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                            if halfFlowerLitPetals.contains(8) {
                                GlowRegionView(shape: HalfFlowerRegion_8(), enabled: true, flashOnAppear: halfFlowerFlashPetals.contains(8), breathSyncStart: halfFlowerBreathSyncStart)
                            }
                        }
                        .frame(width: dw * s2, height: dh * s2)
                        .position(
                            x: xOff2 + (dx + dw/2) * s2,
                            y: yOff2 + (dy + dh/2) * s2
                        )
                    }

                    if recallMode && currentBackgroundName == "bg2_half_flower" {
                        let baseW: CGFloat = 2496
                        let baseH: CGFloat = 1664

                        // aspectFill
                        let s2 = max(screenW / baseW, screenH / baseH)
                        let xOff2 = (screenW - baseW * s2) * 0.5
                        let yOff2 = (screenH - baseH * s2) * 0.5

                        let dx: CGFloat = 783
                        let dy: CGFloat = 329.5
                        let dw: CGFloat = 936
                        let dh: CGFloat = 849

                        ZStack {
                            PetalHitArea(shape: HalfFlowerRegion_1()) { halfFlowerTap(region: 1) }
                            PetalHitArea(shape: HalfFlowerRegion_2()) { halfFlowerTap(region: 2) }
                            PetalHitArea(shape: HalfFlowerRegion_3()) { halfFlowerTap(region: 3) }
                            PetalHitArea(shape: HalfFlowerRegion_4()) { halfFlowerTap(region: 4) }
                            PetalHitArea(shape: HalfFlowerRegion_5()) { halfFlowerTap(region: 5) }
                            PetalHitArea(shape: HalfFlowerRegion_6()) { halfFlowerTap(region: 6) }
                            PetalHitArea(shape: HalfFlowerRegion_7()) { halfFlowerTap(region: 7) }
                            PetalHitArea(shape: HalfFlowerRegion_8()) { halfFlowerTap(region: 8) }
                        }
                        .frame(width: dw * s2, height: dh * s2)
                        .position(
                            x: xOff2 + (dx + dw/2) * s2,
                            y: yOff2 + (dy + dh/2) * s2
                        )
                    }

                    if currentBackgroundName == "bg2_half_flower" {
                        let baseW: CGFloat = 2496
                        let baseH: CGFloat = 1664

                        let s2 = max(screenW / baseW, screenH / baseH)
                        let xOff2 = (screenW - baseW * s2) * 0.5
                        let yOff2 = (screenH - baseH * s2) * 0.5

                        let dx: CGFloat = 783
                        let dy: CGFloat = 329.5
                        let dw: CGFloat = 936
                        let dh: CGFloat = 849

                        FlowingDashOverlay(shape: FlowerDashArea_936x849())
                            .frame(width: dw * s2, height: dh * s2)
                            .position(
                                x: xOff2 + (dx + dw/2) * s2,
                                y: yOff2 + (dy + dh/2) * s2
                            )
                    }
                }
            }
            .ignoresSafeArea()

         
            if showHelpCard {
                HelpCard {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        helpCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        showHelpCard = false
                    }
                }
                .opacity(helpCardOpacity)
                .transition(.opacity)
                .zIndex(999)
            }

            if showIntroCard {
                MemoryPetalIntroCard {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        introCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showIntroCard = false
                        introDismissed = true

                        if !didScheduleChoices {
                            didScheduleChoices = true

                            glowVisible = true

                            choiceTask?.cancel()
                            choiceTask = nil
                            choiceTask = Task {
                                try? await Task.sleep(nanoseconds: 5_000_000_000)
                                guard !Task.isCancelled else { return }

                                await MainActor.run {
                                    glowVisible = false

                                    setBackgroundCrossfade(to: "bg2_empty")
                                    choiceStep = 1
                                    choiceOpacity = 0.0
                                }

                                try? await Task.sleep(nanoseconds: 50_000_000)
                                guard !Task.isCancelled else { return }

                                await MainActor.run {
                                    withAnimation(.easeInOut(duration: 0.28)) {
                                        choiceOpacity = 1.0
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(introCardOpacity)
            }

            if showRecallCard {
                MemoryPetalRecallCard {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        recallCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        showRecallCard = false

                        setBackgroundCrossfade(to: "bg2_half_flower")

                        recallMode = true
                        recalledPetals = []
                        petalTargetTapCount = 0
                        petalNonTargetTapCount = 0
                        halfFlowerTappedPetals = []
                        halfFlowerLitPetals = []
                        halfFlowerFlashPetals = []
                        halfFlowerShadowPetals = []
                        didSetHalfFlowerBreathSync = false
                        halfFlowerBreathSyncStart = Date()
                    }
                }
                .padding(.horizontal, 24)
                .opacity(recallCardOpacity)
            }

            if showCongratsCard {
                MemoryPetalCongratsCard {
                    handleCongratsNext()
                }
                .padding(.horizontal, 24)
                .opacity(congratsCardOpacity)
                .transition(.opacity)
                .zIndex(998)
            }

            if showResultCard {
                MemoryPetalResultCard2(
                    onReplay: {
                        withAnimation(.easeInOut(duration: 0.28)) {
                            resultCardOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            showResultCard = false
                            didScheduleResultCard = false

                            // reset key states
                            glowVisible = false
                            choiceTask?.cancel()
                            choiceTask = nil

                            choiceStep = 0
                            choiceOpacity = 0.0
                            didScheduleChoices = false
                            nightChoice = nil
                            soundChoice = nil

                            showRecallCard = false
                            recallCardOpacity = 0.0
                            recallMode = false
                            recalledPetals = []
                            petalTargetTapCount = 0
                            petalNonTargetTapCount = 0

                            halfFlowerTappedPetals = []
                            halfFlowerLitPetals = []
                            halfFlowerFlashPetals = []
                            halfFlowerShadowPetals = []
                            didSetHalfFlowerBreathSync = false
                            halfFlowerBreathSyncStart = Date()

                            // back to start background + intro card
                            setBackgroundCrossfade(to: "bg2_petal_triplet")
                            introDismissed = false
                            showIntroCard = true
                            introCardOpacity = 0.0

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    introCardOpacity = 1.0
                                }
                            }
                        }
                    },
                    onBackToGarden: {
                        MindGardenMetricsStore.shared.recordPetals(
                            targetTaps: petalTargetTapCount,
                            nonTargetTaps: petalNonTargetTapCount
                        )
                        onFinishedReturnToGarden()
                    }
                )
                .padding(.horizontal, 24)
                .opacity(resultCardOpacity)
            }

            if choiceStep == 1 {
                NightChoiceCard(
                    onPick: { pick in
                        nightChoice = pick
                        withAnimation(.easeInOut(duration: 0.28)) {
                            choiceOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            choiceStep = 2
                            choiceOpacity = 0.0
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.28)) {
                                    choiceOpacity = 1.0
                                }
                            }
                        }
                    }
                )
                .padding(.horizontal, 24)
                .opacity(choiceOpacity)
            }

            if choiceStep == 2 {
                SoundChoiceCard(
                    onPick: { pick in
                        soundChoice = pick
                        withAnimation(.easeInOut(duration: 0.28)) {
                            choiceOpacity = 0.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                            choiceStep = 0
                            choiceOpacity = 0.0

                            showRecallCard = true
                            recallCardOpacity = 0.0

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                withAnimation(.easeInOut(duration: 0.35)) {
                                    recallCardOpacity = 1.0
                                }
                            }
                        }
                    }
                )
                .padding(.horizontal, 24)
                .opacity(choiceOpacity)
            }

            VStack {
                HStack {
                    SecondGlassIconButton(
                        systemName: "chevron.left",
                        action: { onClose() }
                    )
                    .padding(.leading, 20)
                    .padding(.top, 16)

                    Spacer()

                    SecondBGMIconButton(
                        isOn: bgmOn,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                bgmOn.toggle()
                            }
                            if bgmOn {
                                BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
                            } else {
                                BGMPlayer.shared.stop()
                            }
                        }
                    )
                    .padding(.trailing, 10)
                    .padding(.top, 16)

                    SecondGlassIconButton(
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
                    .padding(.top, 16)
                }
                Spacer()
            }
            

            
        }
        .onAppear {
            introDismissed = false
            showIntroCard = true
            introCardOpacity = 0.0

            glowVisible = false
            choiceTask?.cancel()
            choiceTask = nil

            bgA = "bg2_petal_triplet"
            bgB = "bg2_petal_triplet"
            showB = false

            choiceStep = 0
            choiceOpacity = 0.0
            didScheduleChoices = false
            nightChoice = nil
            soundChoice = nil

            showRecallCard = false
            recallCardOpacity = 0.0
            recallMode = false
            recalledPetals = []
            halfFlowerTappedPetals = []
            halfFlowerLitPetals = []
            halfFlowerFlashPetals = []
            halfFlowerShadowPetals = []
            didSetHalfFlowerBreathSync = false
            halfFlowerBreathSyncStart = Date()

            showResultCard = false
            resultCardOpacity = 0.0
            didScheduleResultCard = false

            showCongratsCard = false
            congratsCardOpacity = 0.0

            showHelpCard = false
            helpCardOpacity = 0.0

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    introCardOpacity = 1.0
                }
            }
        }
    }

    private func setBackgroundCrossfade(to newName: String, duration: Double = 0.22) {
        let current = showB ? bgB : bgA
        if current == newName { return }

        if showB {
            bgA = newName
        } else {
            bgB = newName
        }

        withAnimation(.easeInOut(duration: duration)) {
            showB.toggle()
        }
    }

    private var currentBackgroundName: String {
        showB ? bgB : bgA
    }

    private let halfFlowerCorrectRegions: Set<Int> = [2, 5, 7]

    private func halfFlowerTap(region id: Int) {
        if halfFlowerCorrectRegions.contains(id) {
            petalTargetTapCount += 1
        } else {
            petalNonTargetTapCount += 1
        }

        // keep original set record
        halfFlowerTappedPetals.insert(id)

        if !halfFlowerCorrectRegions.contains(id) {
            halfFlowerShadowPetals.insert(id)
            checkHalfFlowerDone()
            return
        }

        guard !halfFlowerLitPetals.contains(id) else {
            checkHalfFlowerDone()
            return
        }

        halfFlowerLitPetals.insert(id)
        halfFlowerFlashPetals.insert(id)

        if !didSetHalfFlowerBreathSync {
            // Align the global breathing phase to start at the flash peak moment.
            // (flash ramp duration = 0.22s)
            halfFlowerBreathSyncStart = Date().addingTimeInterval(0.22)
            didSetHalfFlowerBreathSync = true
        }

        // flash only once, then fall back to normal breathing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            halfFlowerFlashPetals.remove(id)
        }

        checkHalfFlowerDone()
    }

    private func checkHalfFlowerDone() {
        if halfFlowerCorrectRegions.isSubset(of: halfFlowerLitPetals) {
            recallMode = false

            guard !didScheduleResultCard else { return }
            didScheduleResultCard = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showCongratsCard = true
                congratsCardOpacity = 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.30)) {
                        congratsCardOpacity = 1.0
                    }
                }
            }
            return
        }
    }

    private func handleCongratsNext() {
        withAnimation(.easeInOut(duration: 0.30)) {
            congratsCardOpacity = 0.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            showCongratsCard = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                setBackgroundCrossfade(to: "bg2_flower", duration: 0.35)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showResultCard = true
                    resultCardOpacity = 0.0

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            resultCardOpacity = 1.0
                        }
                    }
                }
            }
        }
    }
}

private struct PetalHitArea<S: Shape>: View {
    let shape: S
    let onTap: () -> Void

    var body: some View {
        shape
            .fill(Color.clear)
            .contentShape(shape)
            .onTapGesture(perform: onTap)
            .allowsHitTesting(true)
    }
}

private struct MemoryPetalRecallCard: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 18) {

            Text("Now, recall the three petals you just saw and tap them")
                .font(.system(size: 25, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            Color.clear.frame(height: 26)

            Color.clear.frame(height: 26)

            Button(action: onNext) {
                Text("OK")
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
            .padding(.top, 4)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 48)
        .background {
            MGSoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 620)
        .frame(height: 640)
        .accessibilityElement(children: .combine)
    }
}

private struct MemoryPetalResultCard2: View {
    let onReplay: () -> Void
    let onBackToGarden: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("⛲️")
                .font(.system(size: 34))
                .padding(.bottom, -6)

            Text("The garden thanks your return gaze")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            Color.clear.frame(height: 18)

            Text("Memory and attention are like petals breathing\nclosing and opening\nno matter the pace, what matters is that you pause to feel")
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
        .padding(.horizontal, 22)
        .padding(.vertical, 48)
        .background {
            MGSoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 620)
        .frame(height: 640)
        .accessibilityElement(children: .combine)
    }
}



private struct SecondGlassPill<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .font(.subheadline)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.30), radius: 10, x: 0, y: 6)
    }
}

private struct NightChoiceCard: View {
    let onPick: (String) -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🌙")
                .font(.system(size: 34))
                .padding(.bottom, -6)

            Text("Not yet...")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            Color.clear.frame(height: 18)

            Text("Choose a night you like")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.86))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

            Color.clear.frame(height: 14)

            VStack(spacing: 12) {
                ChoiceCapsule(title: "Starlight") { onPick("Starlight") }
                ChoiceCapsule(title: "Breeze") { onPick("Breeze") }
                ChoiceCapsule(title: "Green") { onPick("Green") }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 48)
        .background {
            MGSoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 620)
        .accessibilityElement(children: .combine)
    }
}

private struct SoundChoiceCard: View {
    let onPick: (String) -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🍃")
                .font(.system(size: 34))
                .padding(.bottom, -6)

            Text("Next...")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            Color.clear.frame(height: 18)

            Text("Choose a sound you want to hear")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.86))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

            Color.clear.frame(height: 14)

            VStack(spacing: 12) {
                ChoiceCapsule(title: "Crickets") { onPick("Crickets") }
                ChoiceCapsule(title: "Distant water") { onPick("Distant water") }
                ChoiceCapsule(title: "Rustling leaves") { onPick("Rustling leaves") }
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 48)
        .background {
            MGSoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 620)
        .accessibilityElement(children: .combine)
    }
}

private struct ChoiceCapsule: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SecondGlassPill {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))
                    .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }
}

struct GlowRegionView<S: Shape>: View {
    let shape: S
    let enabled: Bool
    let flashOnAppear: Bool
    let breathSyncStart: Date

    init(shape: S,
         enabled: Bool,
         flashOnAppear: Bool = false,
         breathSyncStart: Date = Date()) {
        self.shape = shape
        self.enabled = enabled
        self.flashOnAppear = flashOnAppear
        self.breathSyncStart = breathSyncStart
    }

    @State private var dashPhase: CGFloat = 0
    @State private var didFlashOnce = false

    // flash timing
    @State private var flashStart: Date? = nil

    // rgb(222,157,115)
    private let c = Color(red: 222.0/255.0, green: 157.0/255.0, blue: 115.0/255.0)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let r = max(w, h) * 1.35

            TimelineView(.animation) { context in
                let t = context.date
                let amt = breathingAmount(at: t)

                ZStack {
                    ZStack {
                        shape.fill(glowGradient(center: .top,      endRadius: r * 0.95, amt: amt))
                        shape.fill(glowGradient(center: .center,   endRadius: r * 1.05, amt: amt))
                        shape.fill(glowGradient(center: .bottom,   endRadius: r * 0.95, amt: amt))
                        shape.fill(glowGradient(center: .leading,  endRadius: r * 0.95, amt: amt))
                        shape.fill(glowGradient(center: .trailing, endRadius: r * 0.95, amt: amt))
                    }
                    .blur(radius: lerp(18, 24, amt))
                    .mask(shape)
                    .compositingGroup()
                    .blendMode(.plusLighter)

                    shape
                        .stroke(
                            c.opacity(0.38 * amt),
                            style: StrokeStyle(lineWidth: lerp(12, 18, amt), lineCap: .round, lineJoin: .round)
                        )
                        .blur(radius: lerp(13, 18, amt))
                        .shadow(color: c.opacity(0.50 * amt), radius: lerp(18, 26, amt))
                        .compositingGroup()
                        .blendMode(.screen)

                    if enabled {
                        shape
                            .stroke(
                                c.opacity(0.42),
                                style: StrokeStyle(
                                    lineWidth: 2.4,
                                    lineCap: .round,
                                    lineJoin: .round,
                                    dash: [10, 10],
                                    dashPhase: dashPhase
                                )
                            )
                            .blur(radius: 0.6)
                            .shadow(color: c.opacity(0.22), radius: 5)
                            .compositingGroup()
                            .blendMode(.plusLighter)
                    }
                }
                .frame(width: w, height: h)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            if enabled { startAnimations() } else { stopAnimations() }
        }
        .onChange(of: enabled) { newValue in
            if newValue { startAnimations() } else { stopAnimations() }
        }
        .onChange(of: flashOnAppear) { newValue in
            if newValue {
                // allow one more flash cycle
                didFlashOnce = false
                flashStart = nil
                startAnimations()
            }
        }
    }

    private func glowGradient(center: UnitPoint, endRadius: CGFloat, amt: Double) -> RadialGradient {
        RadialGradient(
            stops: [
                .init(color: c.opacity(0.42 * amt), location: 0.0),
                .init(color: c.opacity(0.18 * amt), location: 0.60),
                .init(color: c.opacity(0.0),        location: 1.0)
            ],
            center: center,
            startRadius: 0,
            endRadius: endRadius
        )
    }

    private func startAnimations() {
        dashPhase = 0
        withAnimation(.linear(duration: 4.6).repeatForever(autoreverses: false)) {
            dashPhase = -200
        }

        // start flash timing if requested
        if flashOnAppear && !didFlashOnce {
            didFlashOnce = true
            flashStart = Date()
        }
    }

    private func stopAnimations() {
        dashPhase = 0
        flashStart = nil
    }

    private func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double {
        a + (b - a) * min(max(t, 0), 1)
    }

    private func breathingAmount(at t: Date) -> Double {
        guard enabled else { return 0 }

        // ① Flash: ramp to peak then hold (local per petal)
        if let fs = flashStart {
            let ramp: TimeInterval = 0.22
            let hold: TimeInterval = 0.34
            let dt = t.timeIntervalSince(fs)

            if dt < 0 { return 0 }
            if dt < ramp {
                // smooth-ish ramp 0 → 1
                return min(max(dt / ramp, 0), 1)
            }
            if dt < (ramp + hold) {
                return 1
            }
            // after flash ends, follow the global breathing phase
        }

        // ② Global synced breathing (same phase across petals)
        let half: TimeInterval = 2.8
        let full = half * 2
        let dt = t.timeIntervalSince(breathSyncStart)
        if dt.isNaN || dt.isInfinite { return 0 }

        let phase = (dt.truncatingRemainder(dividingBy: full)) / full // 0..1
        let amt = 0.5 + 0.5 * cos(2 * Double.pi * phase)
        return min(max(amt, 0), 1)
    }
}

struct PetalGlowArea_319x202: Shape {
    func path(in rect: CGRect) -> Path {
        let minX: CGFloat = 0.516724
        let maxX: CGFloat = 317.517
        let minY: CGFloat = -2.90833
        let maxY: CGFloat = 205.065

        let sx = rect.width / (maxX - minX)
        let sy = rect.height / (maxY - minY)

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x - minX) * sx,
                    y: rect.minY + (y - minY) * sy)
        }

        var path = Path()
        path.move(to: p(74.5167, 13.7597))
        path.addCurve(to: p(0.516724, 97.2597), control1: p(20.2097, 48.405), control2: p(11.7696, 67.7565))
        path.addCurve(to: p(59.5167, 176.26), control1: p(4.75718, 120.78), control2: p(14.5849, 136.873))
        path.addCurve(to: p(175.017, 195.26), control1: p(110.07, 203.46), control2: p(134.655, 205.065))
        path.addCurve(to: p(317.517, 136.26), control1: p(233.335, 173.232), control2: p(264.432, 160.274))
        path.addCurve(to: p(311.017, 81.7597), control1: p(308.491, 117.28), control2: p(304.568, 102.919))
        path.addLine(to: p(311.017, 70.2597))
        path.addCurve(to: p(175.017, 4.25968), control1: p(257.006, 38.5254), control2: p(227.504, 25.8988))
        path.addCurve(to: p(74.5167, 13.7597), control1: p(133.517, -2.90833), control2: p(111.711, 0.127614))
        path.closeSubpath()
        return path
    }
}

struct PetalGlowArea_200x281: Shape {
    func path(in rect: CGRect) -> Path {
        let minX: CGFloat = -0.221843
        let maxX: CGFloat = 198.596
        let minY: CGFloat = 0.625122
        let maxY: CGFloat = 279.625

        let sx = rect.width / (maxX - minX)
        let sy = rect.height / (maxY - minY)

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x - minX) * sx,
                    y: rect.minY + (y - minY) * sy)
        }

        var path = Path()
        path.move(to: p(141.096, 0.625122))
        path.addCurve(to: p(55.5956, 0.625122), control1: p(106.255, 12.3006), control2: p(87.5428, 12.347))
        path.addCurve(to: p(0.595555, 132.625), control1: p(30.0298, 53.2208), control2: p(17.7193, 82.1905))
        path.addCurve(to: p(15.0956, 213.625), control1: p(-0.221843, 177.447), control2: p(4.17058, 192.702))
        path.addCurve(to: p(99.0955, 279.625), control1: p(44.7604, 260.322), control2: p(68.9857, 276.36))
        path.addCurve(to: p(172.596, 230.125), control1: p(124.564, 275.722), control2: p(146.281, 263.22))
        path.addCurve(to: p(198.596, 132.625), control1: p(196.12, 195.615), control2: p(198.304, 173.331))
        path.addLine(to: p(141.096, 0.625122))
        path.closeSubpath()
        return path
    }
}

struct PetalGlowArea_249x259: Shape {
    func path(in rect: CGRect) -> Path {
        let minX: CGFloat = 0.0
        let maxX: CGFloat = 249.0
        let minY: CGFloat = -16.7254
        let maxY: CGFloat = 258.316

        let sx = rect.width / (maxX - minX)
        let sy = rect.height / (maxY - minY)

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x - minX) * sx,
                    y: rect.minY + (y - minY) * sy)
        }

        var path = Path()
        path.move(to: p(55.981, 258.316))
        path.addCurve(to: p(0.980957, 198.316), control1: p(43.2268, 228.578), control2: p(30.0978, 216.226))
        path.addCurve(to: p(55.981, 57.3163), control1: p(8.83478, 193.839), control2: p(30.0008, 114.511))
        path.addCurve(to: p(232.481, 19.8163), control1: p(81.9611, 0.121605), control2: p(188.302, -16.7254))
        path.addCurve(to: p(243.481, 119.816), control1: p(248.389, 55.7335), control2: p(251.606, 77.4111))
        path.addCurve(to: p(181.481, 198.316), control1: p(226.534, 164.863), control2: p(212.21, 186.684))
        path.addLine(to: p(55.981, 258.316))
        path.closeSubpath()
        return path
    }
}

private struct FlowingDashOverlay<S: Shape>: View {
    let shape: S
    @State private var dashPhase: CGFloat = 0

    private let c = Color(red: 222.0/255.0, green: 157.0/255.0, blue: 115.0/255.0)

    var body: some View {
        shape
            .stroke(
                c.opacity(0.55),
                style: StrokeStyle(
                    lineWidth: 2.6,
                    lineCap: .round,
                    lineJoin: .round,
                    dash: [10, 10],
                    dashPhase: dashPhase
                )
            )
            .blur(radius: 0.6)
            .shadow(color: c.opacity(0.22), radius: 6)
            .compositingGroup()
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
            .onAppear {
                dashPhase = 0
                withAnimation(.linear(duration: 6.8).repeatForever(autoreverses: false)) {
                    dashPhase = -460
                }
            }
    }
}

private struct FlowerDashArea_936x849: Shape {
    func path(in rect: CGRect) -> Path {
        let minX: CGFloat = 0.523376
        let maxX: CGFloat = 934.523
        let minY: CGFloat = 0.500549
        let maxY: CGFloat = 847.501

        let sx = rect.width / (maxX - minX)
        let sy = rect.height / (maxY - minY)

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(
                x: rect.minX + (x - minX) * sx,
                y: rect.minY + (y - minY) * sy
            )
        }

        var path = Path()
        path.move(to: p(186.023, 312.501))
        path.addCurve(to: p(147.023, 127.001), control1: p(158.652, 287.355), control2: p(111.949, 220.606))
        path.addCurve(to: p(355.023, 154.001), control1: p(217.669, 78.2272), control2: p(294.16, 85.7633))

        path.move(to: p(186.023, 312.501))
        path.addLine(to: p(355.023, 387.501))

        path.move(to: p(186.023, 312.501))
        path.addCurve(to: p(0.523376, 424.001), control1: p(114.17, 294.642), control2: p(25.1, 341.775))
        path.addCurve(to: p(186.023, 539.001), control1: p(24.3194, 498.407), control2: p(113.362, 546.917))

        path.move(to: p(355.023, 387.501))
        path.addCurve(to: p(417.523, 322.001), control1: p(368.133, 352.911), control2: p(381.735, 338.525))

        path.move(to: p(355.023, 387.501))
        path.addCurve(to: p(355.023, 464.001), control1: p(347.48, 413.854), control2: p(346.65, 430.217))

        path.move(to: p(417.523, 322.001))
        path.addLine(to: p(355.023, 154.001))

        path.move(to: p(417.523, 322.001))
        path.addCurve(to: p(524.023, 322.001), control1: p(455.317, 304.595), control2: p(478.829, 305.477))

        path.move(to: p(355.023, 154.001))
        path.addCurve(to: p(468.023, 0.500549), control1: p(371.342, 27.062), control2: p(446.113, 0.841635))
        path.addCurve(to: p(583.023, 154.001), control1: p(517.902, 7.71182), control2: p(575.646, 53.9913))

        path.move(to: p(583.023, 154.001))
        path.addLine(to: p(524.023, 322.001))

        path.move(to: p(583.023, 154.001))
        path.addCurve(to: p(782.023, 118.001), control1: p(670.85, 70.1313), control2: p(709.971, 97.5377))
        path.addCurve(to: p(749.023, 312.501), control1: p(807.213, 178.326), control2: p(813.719, 246.644))

        path.move(to: p(524.023, 322.001))
        path.addCurve(to: p(583.023, 390.001), control1: p(554.262, 343.066), control2: p(569.505, 356.182))

        path.move(to: p(583.023, 390.001))
        path.addLine(to: p(749.023, 312.501))

        path.move(to: p(583.023, 390.001))
        path.addCurve(to: p(583.023, 464.001), control1: p(590.805, 424.783), control2: p(589.655, 440.117))

        path.move(to: p(749.023, 312.501))
        path.addCurve(to: p(934.523, 423.001), control1: p(837.634, 305.915), control2: p(894.354, 325.463))
        path.addCurve(to: p(746.023, 539.001), control1: p(904.124, 499.824), control2: p(863.707, 537.288))

        path.move(to: p(583.023, 464.001))
        path.addLine(to: p(746.023, 539.001))

        path.move(to: p(583.023, 464.001))
        path.addCurve(to: p(518.523, 534.501), control1: p(568.818, 499.685), control2: p(555.208, 515.501))

        path.move(to: p(746.023, 539.001))
        path.addCurve(to: p(789.023, 724.001), control1: p(812.575, 583.919), control2: p(810.069, 630.972))
        path.addCurve(to: p(588.023, 701.501), control1: p(733.947, 764.611), control2: p(652.768, 759.148))

        path.move(to: p(588.023, 701.501))
        path.addCurve(to: p(469.023, 847.501), control1: p(571.993, 783.518), control2: p(530.435, 831.528))
        path.addCurve(to: p(355.023, 685.501), control1: p(404.327, 825.072), control2: p(359.651, 784.244))

        path.move(to: p(588.023, 701.501))
        path.addLine(to: p(518.523, 534.501))

        path.move(to: p(355.023, 685.501))
        path.addCurve(to: p(147.023, 724.001), control1: p(309.928, 747.131), control2: p(236.899, 769.608))
        path.addCurve(to: p(186.023, 539.001), control1: p(121.779, 618.432), control2: p(128.111, 578.362))

        path.move(to: p(355.023, 685.501))
        path.addLine(to: p(421.023, 534.501))

        path.move(to: p(186.023, 539.001))
        path.addLine(to: p(355.023, 464.001))

        path.move(to: p(518.523, 534.501))
        path.addCurve(to: p(421.023, 534.501), control1: p(480.447, 546.686), control2: p(459.1, 545.172))

        path.move(to: p(421.023, 534.501))
        path.addCurve(to: p(355.023, 464.001), control1: p(387.02, 512.551), control2: p(373.942, 496.183))

        return path
    }
}

private struct HalfFlowerRegionBase {
    static let minX: CGFloat = 0.0
    static let maxX: CGFloat = 936.0
    static let minY: CGFloat = 0.0
    static let maxY: CGFloat = 849.0

    static func map(_ pt: CGPoint, in rect: CGRect) -> CGPoint {
        let sx = rect.width / (maxX - minX)
        let sy = rect.height / (maxY - minY)
        return CGPoint(
            x: rect.minX + (pt.x - minX) * sx,
            y: rect.minY + (pt.y - minY) * sy
        )
    }

    static func regionPath(index i: Int, in rect: CGRect) -> Path {
        func m(_ x: CGFloat, _ y: CGFloat) -> CGPoint { map(CGPoint(x: x, y: y), in: rect) }
        var path = Path()

        switch i {
        case 0:
            path.move(to: m(355.023, 154.001))
            path.addCurve(to: m(468.023, 0.500549),
                          control1: m(371.342, 27.062),
                          control2: m(446.113, 0.841635))
            path.addCurve(to: m(583.023, 154.001),
                          control1: m(517.902, 7.71182),
                          control2: m(575.646, 53.9913))
            path.addLine(to: m(524.023, 322.001))
            path.addLine(to: m(417.523, 322.001))
            path.addLine(to: m(355.023, 154.001))
            path.closeSubpath()

        case 1:
            path.move(to: m(583.023, 154.001))
            path.addCurve(to: m(782.023, 118.001),
                          control1: m(670.85, 70.1313),
                          control2: m(709.971, 97.5377))
            path.addCurve(to: m(749.023, 312.501),
                          control1: m(807.213, 178.326),
                          control2: m(813.719, 246.644))
            path.addLine(to: m(583.023, 390.001))
            path.addCurve(to: m(524.023, 322.001),
                          control1: m(569.505, 356.182),
                          control2: m(554.262, 343.066))
            path.addLine(to: m(583.023, 154.001))
            path.closeSubpath()

        case 2:
            path.move(to: m(583.023, 390.001))
            path.addLine(to: m(749.023, 312.501))
            path.addCurve(to: m(934.523, 423.001),
                          control1: m(837.634, 305.915),
                          control2: m(894.354, 325.463))
            path.addCurve(to: m(746.023, 539.001),
                          control1: m(904.124, 499.824),
                          control2: m(863.707, 537.288))
            path.addLine(to: m(583.023, 464.001))
            path.addCurve(to: m(583.023, 390.001),
                          control1: m(589.655, 440.117),
                          control2: m(590.805, 424.783))
            path.closeSubpath()

        case 3:
            path.move(to: m(583.023, 464.001))
            path.addCurve(to: m(518.523, 534.501),
                          control1: m(555.208, 515.501),
                          control2: m(568.818, 499.685))
            path.addLine(to: m(588.023, 701.501))
            path.addCurve(to: m(789.023, 724.001),
                          control1: m(652.768, 759.148),
                          control2: m(733.947, 764.611))
            path.addCurve(to: m(746.023, 539.001),
                          control1: m(810.069, 630.972),
                          control2: m(812.575, 583.919))
            path.addLine(to: m(583.023, 464.001))
            path.closeSubpath()

        case 4:
            path.move(to: m(421.023, 534.501))
            path.addCurve(to: m(518.523, 534.501),
                          control1: m(459.1, 545.172),
                          control2: m(480.447, 546.686))
            path.addLine(to: m(588.023, 701.501))
            path.addCurve(to: m(469.023, 847.501),
                          control1: m(530.435, 831.528),
                          control2: m(571.993, 783.518))
            path.addCurve(to: m(355.023, 685.501),
                          control1: m(404.327, 825.072),
                          control2: m(359.651, 784.244))
            path.addLine(to: m(421.023, 534.501))
            path.closeSubpath()

        case 5:
            path.move(to: m(355.023, 464.001))
            path.addCurve(to: m(421.023, 534.501),
                          control1: m(373.942, 496.183),
                          control2: m(387.02, 512.551))
            path.addLine(to: m(355.023, 685.501))
            path.addCurve(to: m(147.023, 724.001),
                          control1: m(236.899, 769.608),
                          control2: m(309.928, 747.131))
            path.addCurve(to: m(186.023, 539.001),
                          control1: m(128.111, 578.362),
                          control2: m(121.779, 618.432))
            path.addLine(to: m(355.023, 464.001))
            path.closeSubpath()

        case 6:
            path.move(to: m(186.023, 312.501))
            path.addLine(to: m(355.023, 387.501))
            path.addCurve(to: m(355.023, 464.001),
                          control1: m(346.65, 430.217),
                          control2: m(347.48, 413.854))
            path.addLine(to: m(186.023, 539.001))
            path.addCurve(to: m(0.523376, 424.001),
                          control1: m(113.362, 546.917),
                          control2: m(24.3194, 498.407))
            path.addCurve(to: m(186.023, 312.501),
                          control1: m(25.1, 341.775),
                          control2: m(114.17, 294.642))
            path.closeSubpath()

        default:
            path.move(to: m(186.023, 312.501))
            path.addCurve(to: m(147.023, 127.001),
                          control1: m(158.652, 287.355),
                          control2: m(111.949, 220.606))
            path.addCurve(to: m(355.023, 154.001),
                          control1: m(217.669, 78.2272),
                          control2: m(294.16, 85.7633))
            path.addLine(to: m(417.523, 322.001))
            path.addCurve(to: m(355.023, 387.501),
                          control1: m(381.735, 338.525),
                          control2: m(368.133, 352.911))
            path.addLine(to: m(186.023, 312.501))
            path.closeSubpath()
        }

        return path
    }
}

private struct HalfFlowerRegion_1: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 0, in: rect) } }
private struct HalfFlowerRegion_2: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 1, in: rect) } }
private struct HalfFlowerRegion_3: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 2, in: rect) } }
private struct HalfFlowerRegion_4: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 3, in: rect) } }
private struct HalfFlowerRegion_5: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 4, in: rect) } }
private struct HalfFlowerRegion_6: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 5, in: rect) } }
private struct HalfFlowerRegion_7: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 6, in: rect) } }
private struct HalfFlowerRegion_8: Shape { func path(in rect: CGRect) -> Path { HalfFlowerRegionBase.regionPath(index: 7, in: rect) } }

private struct SecondGlassIconButton: View {
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

private struct SecondBGMIconButton: View {
    let isOn: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .contentTransition(
                    .symbolEffect(.replace.magic(fallback: .downUp.wholeSymbol), options: .nonRepeating)
                )
                .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
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
        .contentShape(Circle())
    }
}

private struct MemoryPetalIntroCard: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text("🪷")
                .font(.system(size: 34))
                .padding(.bottom, -6)

            Text("Memory in the flower bed")
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.92))
                .multilineTextAlignment(.center)
                .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

            Color.clear.frame(height: 26)

            VStack(spacing: 14) {
                Text("In the mind's flower bed, some blooms close for a while.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("Give it a pause, and it opens again, leaving traces of growth.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("Memory is like that too—hold just a small piece for now.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Text("Three glowing petals will appear.\nRemember where they are.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.40), radius: 4, x: 0, y: 2)
                    .padding(.top, 2)
            }

            Color.clear.frame(height: 26)

            Button(action: onNext) {
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
            .padding(.top, 4)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 48)
        .background {
            MGSoftEdgeSolidCardBackground(
                cornerRadius: 28,
                feather: 14,
                featherBlur: 18
            )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
        }
        .frame(maxWidth: 620)
        .frame(height: 640)
        .accessibilityElement(children: .combine)
    }
}

private struct MGSoftEdgeSolidCardBackground: View {
    let cornerRadius: CGFloat
    let feather: CGFloat
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
        .mask(
            shape
                .fill(Color.white)
                .blur(radius: featherBlur)
        )
        .shadow(color: Color.black.opacity(0.20), radius: 22, x: 0, y: 12)
    }
}


private struct HelpCard: View {
    let onDismiss: () -> Void

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

                            Text("A small exercise for Short-term Memory.\nRemember the petals' positions, resist distraction,\nthen recall them.")

                            Text("It helps train Short-term Memory\nand resistance to distraction.")
                                .foregroundStyle(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(.white)
                    }

                    Button(action: onDismiss) {
                        Text("Got it")
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
                    .padding(.top, 4)
                }
                .padding(.horizontal, 22)
                .padding(.vertical, 48)
                .frame(width: cardW, height: 495)
                .background {
                    MGSoftEdgeSolidCardBackground(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18
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

private struct MemoryPetalCongratsCard: View {
    let onNext: () -> Void

    var body: some View {
        GeometryReader { geo in
            let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

            VStack(spacing: 18) {

                Text("You found all the petals")
                    .font(.system(size: 25, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                Color.clear.frame(height: 18)

                Text("Petals open and close. You don’t need to chase them.")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.86))
                    .multilineTextAlignment(.center)
                    .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.14))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.28), lineWidth: 1)
                }
                .padding(.top, 32)
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 48)
            .frame(width: cardW, height: 495)
            .background {
                MGSoftEdgeSolidCardBackground(
                    cornerRadius: 28,
                    feather: 14,
                    featherBlur: 18
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
