import SwiftUI

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var showFirstInteraction = false

    @State private var showIntro = true

    // Entry gate for Interaction 1
    @State private var glowEnabled = false

    @State private var backgroundName: String = "background"
    private let introDismissDuration: Double = 0.4

    // Post-return mist prompt state
    @State private var showPostMist = false
    @State private var pendingShowPostMist = false
    @State private var pendingShowPostMistFromSecond = false
    @State private var pendingShowPostMistFromThird = false

    // postMistMode: 0=after I1, 1=after I2, 2=after I3
    @State private var postMistMode: Int = 0

    @State private var postMistStep: Int = 0
    @State private var postMistContentOpacity: CGFloat = 1.0

    // Gate for Interaction 2 entry
    @State private var glow2Enabled = false

    // Gate for Interaction 3 entry
    @State private var glow3Enabled = false

    // Navigation / presentation flags
    @State private var showSecondInteraction = false

    @State private var showThirdInteraction = false
    @State private var showMindReport = false

    // Final cards
    @State private var showGardenFinalCard = false
    @State private var gardenFinalCardOpacity: Double = 0.0

    @State private var showReportReadyCard = false
    @State private var reportReadyCardOpacity: Double = 0.0

    // Center CTA (shown at the very end)
    @State private var showTodayReportButton = false

    // Top-right BGM toggle (MindGarden tab only)
    @AppStorage("bgmOn") private var topRightButtonOn: Bool = true

    private let promptYRatio: CGFloat = 0.42

    var body: some View {
        ZStack {

            // Background
            ZStack {
                Color(uiColor: .systemBackground)

                GardenBackground(imageName: backgroundName)
                    .ignoresSafeArea()
                    .opacity(selectedTab == 0 ? 1.0 : 0.0)
            }
            .animation(.easeInOut(duration: 0.5), value: selectedTab)

            // Interaction 2 entry (bg2)
            if selectedTab == 0, backgroundName == "background2", glow2Enabled {
                ZStack {
                    GlowLine2()
                        .zIndex(2)

                    GlowFrameShape2()
                        .fill(Color.clear)
                        .contentShape(GlowFrameShape2())
                        .onTapGesture {
                            showSecondInteraction = true
                        }
                        .zIndex(3)
                }
            }

            // Interaction 3 entry (bg3)
            if selectedTab == 0, backgroundName == "background3", glow3Enabled {
                ZStack {
                    GlowLine3()
                        .zIndex(2)

                    GlowFrameShape3()
                        .fill(Color.clear)
                        .contentShape(GlowFrameShape3())
                        .onTapGesture {
                            showThirdInteraction = true
                        }
                        .zIndex(3)
                }
            }

            // Content
            ZStack {
                GardenOverlay(glowEnabled: $glowEnabled) {
                    showFirstInteraction = true
                }
                .opacity(selectedTab == 0 ? 1.0 : 0.0)
                .allowsHitTesting(selectedTab == 0)

                ArticlesRootView()
                    .opacity(selectedTab == 1 ? 1.0 : 0.0)
                    .allowsHitTesting(selectedTab == 1)
            }
            .animation(nil, value: selectedTab)

            // Top segmented control
            VStack(spacing: 0) {
                ZStack {
                    Picker("", selection: $selectedTab) {
                        Text("MindGarden").tag(0)
                        Text("Articles").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .controlSize(.large)
                    .padding(.horizontal, 450)
                    .environment(\.colorScheme, selectedTab == 0 ? .dark : .light)

                    HStack {
                        Spacer()

                        if selectedTab == 0 {
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    topRightButtonOn.toggle()
                                }

                                if topRightButtonOn {
                                 
                                    BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
                                } else {
                                 
                                    BGMPlayer.shared.stop()
                                }
                            } label: {
                                Image(systemName: topRightButtonOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.white.opacity(0.92))
                                    .contentTransition(
                                        .symbolEffect(
                                            .replace.magic(fallback: .downUp.wholeSymbol),
                                            options: .nonRepeating
                                        )
                                    )
                                    .frame(width: 48, height: 48)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                Circle()
                                                    .fill(Color.black.opacity(0.12))
                                            )
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.28), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 20)
                        }
                    }
                }

                Spacer(minLength: 0)
            }

            // Intro
            if showIntro {
                IntroCardView {
                    withAnimation(.easeOut(duration: introDismissDuration)) {
                        showIntro = false
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }

            // Post-return mist prompt
            if showPostMist {
                ZStack {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .contentShape(Rectangle())
                        .onTapGesture { }

                    GeometryReader { proxy in
                        MistPromptView(
                            title: postMistTitle,
                            subtitle: postMistSubtitle,
                            actionStyle: postMistActionStyle,
                            contentOpacity: postMistContentOpacity
                        ) {
                            handlePostMistAction()
                        }
                        .frame(maxWidth: 420)
                        .position(
                            x: proxy.size.width * 0.5,
                            y: proxy.size.height * promptYRatio
                        )
                    }
                }
                .transition(.opacity)
                .zIndex(20)
            }

            // Final completion card
            if showGardenFinalCard {
                GardenFinalCard {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        gardenFinalCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        showGardenFinalCard = false

                        showReportReadyCard = true
                        reportReadyCardOpacity = 0.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                reportReadyCardOpacity = 1.0
                            }
                        }
                    }
                }
                .opacity(gardenFinalCardOpacity)
                .transition(.opacity)
                .zIndex(30)
            }

            // Report-ready card
            if showReportReadyCard {
                ReportReadyCard {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        reportReadyCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        showReportReadyCard = false
                        showTodayReportButton = true
                    }
                }
                .opacity(reportReadyCardOpacity)
                .transition(.opacity)
                .zIndex(31)
            }

            // Center CTA
            if showTodayReportButton && selectedTab == 0 {
                Button {
                    showMindReport = true
                } label: {
                    Text("Today's Mind Report")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.85))
                        .padding(.horizontal, 28)
                        .padding(.vertical, 18)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color(red: 246.0/255.0, green: 223.0/255.0, blue: 215.0/255.0))
                        }
                        .overlay {
                            Capsule(style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        }
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                }
                .buttonStyle(.plain)
                .offset(y: 80)
                .zIndex(5)
            }
        }

        // Full-screen navigation
        .onAppear {
            if topRightButtonOn {
                BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
            }
        }
        .fullScreenCover(isPresented: $showFirstInteraction) {
            FirstInteractionView(
                onFinishedReturn: {
                    glowEnabled = false
                    selectedTab = 0
                    postMistMode = 0
                    pendingShowPostMist = true
                    showFirstInteraction = false
                },
                onClose: {
                    showFirstInteraction = false
                }
            )
        }

        // Interaction 2
        .fullScreenCover(isPresented: $showSecondInteraction) {
            SecondInteractionView(
                onClose: {
                    showSecondInteraction = false
                },
                onFinishedReturnToGarden: {
                    glow2Enabled = false
                    glow3Enabled = false
                    selectedTab = 0
                    postMistMode = 1
                    pendingShowPostMistFromSecond = true
                    showSecondInteraction = false
                }
            )
        }

        // Interaction 3
        .fullScreenCover(isPresented: $showThirdInteraction) {
            ThirdInteractionView(
                onClose: {
                    showThirdInteraction = false
                },
                onBackToGarden: {
                    glow3Enabled = false
                    selectedTab = 0
                    postMistMode = 2
                    pendingShowPostMistFromThird = true
                    showThirdInteraction = false
                }
            )
        }

        // Show mist after dismissing Interaction 1
        .onChange(of: showFirstInteraction) { oldValue, newValue in
            guard oldValue == true, newValue == false else { return }
            guard pendingShowPostMist else { return }

            pendingShowPostMist = false

            postMistStep = 0
            postMistContentOpacity = 0
            glow2Enabled = false
            glow3Enabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showPostMist = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        postMistContentOpacity = 1
                    }
                }
            }
        }

        // Show mist after dismissing Interaction 2
        .onChange(of: showSecondInteraction) { oldValue, newValue in
            guard oldValue == true, newValue == false else { return }
            guard pendingShowPostMistFromSecond else { return }

            pendingShowPostMistFromSecond = false

            postMistStep = 0
            postMistContentOpacity = 0

            glow2Enabled = false
            glow3Enabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showPostMist = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        postMistContentOpacity = 1
                    }
                }
            }
        }

        // Show mist after dismissing Interaction 3
        .onChange(of: showThirdInteraction) { oldValue, newValue in
            guard oldValue == true, newValue == false else { return }
            guard pendingShowPostMistFromThird else { return }

            pendingShowPostMistFromThird = false

            postMistStep = 0
            postMistContentOpacity = 0

            glow3Enabled = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showPostMist = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        postMistContentOpacity = 1
                    }
                }
            }
        }

        // Mind report
        .fullScreenCover(isPresented: $showMindReport) {
            MindReportView {
                showMindReport = false
            }
        }
    }

    // MARK: - Mist prompt text

    private var postMistTitle: String {
        if postMistMode == 2 {
            // Third interaction: return-to-garden mist (single segment)
            return "Vines green under your gaze."
        }

        if postMistMode == 1 {
            switch postMistStep {
            case 0: return "Flowers bloom when you remember them."
            case 1: return "Beneath the beds, bare vines wait for spring."
            default: return "Touch the vines again."
            }
        } else {
            switch postMistStep {
            case 0: return "The night sky deepens under your gaze."
            case 1: return "Under starlight, the beds hold unopened buds."
            default: return "Explore the beds again."
            }
        }
    }

    private var postMistSubtitle: String? {
        if postMistMode == 2 { return nil }
        return postMistStep == 2 ? "After closing, tap the glowing area." : nil
    }

    private var postMistActionStyle: MistPromptActionStyle {
        if postMistMode == 2 {
            return .close
        }
        return postMistStep < 2 ? .next : .close
    }

    // MARK: - Post-mist action handler
    private func handlePostMistAction() {
        // Mode 2: bg4 + final card
        if postMistMode == 2 {

            withAnimation(.easeInOut(duration: 0.20)) {
                postMistContentOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                let mistFade: Double = 0.25
                withAnimation(.easeInOut(duration: mistFade)) {
                    showPostMist = false
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + mistFade) {
                    backgroundName = "background4"

                    showGardenFinalCard = true
                    gardenFinalCardOpacity = 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            gardenFinalCardOpacity = 1.0
                        }
                    }
                }
            }
            return
        }

        if postMistStep == 0 {

            let fadeOut: Double = 1.0
            let postDelay: Double = 0.7
            let fadeIn: Double = 0.25

            withAnimation(.easeInOut(duration: fadeOut)) {
                showPostMist = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut) {

                // Switch background after step 0
                backgroundName = (postMistMode == 1 ? "background3" : "background2")

                DispatchQueue.main.asyncAfter(deadline: .now() + postDelay) {

                    postMistStep = 1
                    postMistContentOpacity = 0

                    withAnimation(.easeInOut(duration: fadeIn)) {
                        showPostMist = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            postMistContentOpacity = 1
                        }
                    }
                }
            }
            return
        }

        if postMistStep < 2 {
            withAnimation(.easeInOut(duration: 0.18)) {
                postMistContentOpacity = 0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                postMistStep += 1
                withAnimation(.easeInOut(duration: 0.22)) {
                    postMistContentOpacity = 1
                }
            }
        } else {
            // Enable next entry gate after closing
            withAnimation(.easeInOut(duration: 0.20)) {
                postMistContentOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                let mistFade: Double = 0.25
                withAnimation(.easeInOut(duration: mistFade)) {
                    showPostMist = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + mistFade) {
                    if postMistMode == 0 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            glow2Enabled = true
                        }
                    } else if postMistMode == 1 {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            glow3Enabled = true
                        }
                    }
                }
            }
        }
    }
}


private struct GardenFinalCard: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 18) {

                        Text("Your Mind Garden is full.")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Color.clear.frame(height: 18)

                        VStack(spacing: 10) {
                            Text("When starlight fills the sky,\nflowers open at the center,\nvines stretch in green,")

                            Text("Thank you for every touch,\nfor shaping this hidden place into its gentlest form.")
                        }
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Text("You may hand the iPad back to your child now.")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
                            .padding(.top, 4)

                        Button(action: onClose) {
                            Text("Got it.")
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

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    MGSoftEdgeSolidCardBackground(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: .mindGardenWarm
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

// MARK: - Solid card background (local)
private struct MGSoftEdgeSolidCardBackground: View {
    let cornerRadius: CGFloat
    let feather: CGFloat
    let featherBlur: CGFloat
    let fill: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            // Base fill
            shape
                .fill(fill)

            // Inner fill
            shape
                .inset(by: max(0, feather - 4))
                .fill(fill)
        }
        .compositingGroup()

        // Feathered alpha mask
        .mask(
            shape
                .fill(Color.white)
                .blur(radius: featherBlur)
        )

        // Depth shadow
        .shadow(color: Color.black.opacity(0.20), radius: 22, x: 0, y: 12)
    }
}


private struct ReportReadyCard: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 18) {

                        Text("All of today's interactions are complete")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Color.clear.frame(height: 18)

                        Text("Now, you can view today's Mind Report.")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.86))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Color.clear.frame(height: 22)

                        Button(action: onClose) {
                            Text("Got it.")
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

                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 32)
                .frame(width: cardW, height: 495)
                .background {
                    MGSoftEdgeSolidCardBackground(
                        cornerRadius: 28,
                        feather: 14,
                        featherBlur: 18,
                        fill: .mindGardenWarm
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


