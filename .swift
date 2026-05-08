import SwiftUI

struct ContentView: View {

    @State private var selectedTab = 0
    @State private var showFirstInteraction = false

    @State private var showIntro = true

    // ✅ 夜空发光（GardenOverlay 内部在最后一个雾气 X 消失后才会置 true）
    @State private var glowEnabled = false

    @State private var backgroundName: String = "background"
    private let introDismissDuration: Double = 0.4

    // ===== 回到花园后三段雾气 =====
    @State private var showPostMist = false
    @State private var pendingShowPostMist = false
    @State private var pendingShowPostMistFromSecond = false
    @State private var pendingShowPostMistFromThird = false

    /// 0 = 第一互动回花园雾气；1 = 第二互动回花园雾气；2 = 第三互动回花园雾气
    @State private var postMistMode: Int = 0

    @State private var postMistStep: Int = 0
    @State private var postMistContentOpacity: CGFloat = 1.0

    // ✅ GlowLine2 出现开关（最后一个雾气 X 消失后才开）
    @State private var glow2Enabled = false

    // ✅ 第三条 GlowLine3 出现开关（第二互动雾气关闭后才开）
    @State private var glow3Enabled = false

    // ✅ 第二互动页面
    @State private var showSecondInteraction = false

    // ✅ 第三互动页面
    @State private var showThirdInteraction = false

    // ✅ 心灵报告页面
    @State private var showMindReport = false

    // ✅ 最终完成弹窗（调试：先在开始就显示，方便看效果）
    @State private var showGardenFinalCard = false
    @State private var gardenFinalCardOpacity: Double = 0.0

    // ✅ 报告提示弹窗（在“心灵花园已盈满”之后）
    @State private var showReportReadyCard = false
    @State private var reportReadyCardOpacity: Double = 0.0

    // ✅ 中央按钮：进入今日心灵报告（最终阶段才出现）
    @State private var showTodayReportButton = false

    // ✅ 顶部右侧按钮（与 segmented picker 同行）——背景音乐开关
    @AppStorage("bgmOn") private var topRightButtonOn: Bool = true

    private let promptYRatio: CGFloat = 0.42

    var body: some View {
        ZStack {

            // ===== 背景层 =====
            ZStack {
                Color(uiColor: .systemBackground)

                GardenBackground(imageName: backgroundName)
                    .ignoresSafeArea()
                    .opacity(selectedTab == 0 ? 1.0 : 0.0)
            }
            .animation(.easeInOut(duration: 0.5), value: selectedTab)

            // ✅ GlowLine2：background2 且启用时显示，并可点击进入第二互动
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

            // ✅ GlowLine3：background3 且启用时显示（第三个发光+虚线流动区域）
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

            // ===== 内容层 =====
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

            // ===== 顶部切换 =====
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
                                    // 恢复播放
                                    BGMPlayer.shared.startLoopFromDataAsset(named: "bgm")
                                } else {
                                    // 暂停/停止
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

            // ===== IntroCardView =====
            if showIntro {
                IntroCardView {
                    withAnimation(.easeOut(duration: introDismissDuration)) {
                        showIntro = false
                    }
                }
                .transition(.opacity)
                .zIndex(10)
            }

            // ===== 回到花园后的雾气 =====
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

            // ✅ 最终完成弹窗（第三互动回花园后）
            if showGardenFinalCard {
                GardenFinalCard {
                    withAnimation(.easeInOut(duration: 0.20)) {
                        gardenFinalCardOpacity = 0.0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                        showGardenFinalCard = false

                        // ✅ 弹出“可查看心灵报告”弹窗
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

            // ✅ 报告提示弹窗（在“心灵花园已盈满”之后）
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

            // ✅ 屏幕中央按钮（调试预览）
            if showTodayReportButton && selectedTab == 0 {
                Button {
                    showMindReport = true
                } label: {
                    Text("今日心灵报告")
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

        // ===== AR 全屏 =====
        .onAppear {
            // ✅ 默认开启背景音乐
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

        // ✅ 第二互动页面
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

        // ✅ 第三互动页面
        .fullScreenCover(isPresented: $showThirdInteraction) {
            ThirdInteractionView(
                onClose: {
                    showThirdInteraction = false
                },
                onBackToGarden: {
                    // ✅ 点击“回到花园”：关闭 GlowLine3 的发光与虚线流动，并弹出最终雾气
                    glow3Enabled = false
                    selectedTab = 0
                    postMistMode = 2
                    pendingShowPostMistFromThird = true
                    showThirdInteraction = false
                }
            )
        }

        // ✅ fullScreenCover 关闭后再显示雾气（第一互动）
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

        // ✅ fullScreenCover 关闭后再显示雾气（第二互动）
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

        // ✅ fullScreenCover 关闭后再显示雾气（第三互动）
        .onChange(of: showThirdInteraction) { oldValue, newValue in
            guard oldValue == true, newValue == false else { return }
            guard pendingShowPostMistFromThird else { return }

            pendingShowPostMistFromThird = false

            postMistStep = 0
            postMistContentOpacity = 0

            // ✅ 第三套雾气期间强制关闭 GlowLine3
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

        // ✅ 心灵报告页面
        .fullScreenCover(isPresented: $showMindReport) {
            MindReportView {
                showMindReport = false
            }
        }
    }

    // MARK: - 雾气文案

    private var postMistTitle: String {
        if postMistMode == 2 {
            // 第三互动回花园雾气（只有一段）
            return "藤蔓因被您凝望而染翠蜿蜒"
        }

        if postMistMode == 1 {
            switch postMistStep {
            case 0: return "花朵因被您铭记而嫣然绽放"
            case 1: return "而花圃之下是褐枝待苏的藤蔓"
            default: return "请继续触碰藤蔓吧"
            }
        } else {
            switch postMistStep {
            case 0: return "夜空因您的注视而深邃灿烂"
            case 1: return "而星光之下是含苞待放的花圃"
            default: return "请继续探索花圃吧"
            }
        }
    }

    private var postMistSubtitle: String? {
        if postMistMode == 2 { return nil }
        return postMistStep == 2 ? "关闭后请轻触发光区域" : nil
    }

    private var postMistActionStyle: MistPromptActionStyle {
        if postMistMode == 2 {
            return .close
        }
        return postMistStep < 2 ? .next : .close
    }

    // MARK: - 点击 “> / X” 行为
    private func handlePostMistAction() {

        // ✅ 第三互动：只有一段雾气（X 关闭）-> 切 background4 -> 弹最终卡
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

        // 第 1 段 -> 第 2 段：雾气整体消失再出现 + 切背景
        if postMistStep == 0 {

            let fadeOut: Double = 1.0
            let postDelay: Double = 0.7
            let fadeIn: Double = 0.25

            withAnimation(.easeInOut(duration: fadeOut)) {
                showPostMist = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOut) {

                // ✅ 第 1 段结束后切背景：第一互动 -> background2；第二互动 -> background3
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

        // 第 2 -> 第 3：雾气不动，只让文字渐出/渐入
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
            // 关闭：雾气完全消失那一刻才开 GlowLine2 / GlowLine3
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
                // ✅ 与 VineInstructionCard 一致：外层等效 padding(.horizontal, 24)
                let cardW = min(620.0, max(0.0, geo.size.width - 48.0))

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 18) {

                

                        Text("您的心灵花园已盈满")
                            .font(.system(size: 30, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Color.clear.frame(height: 18)

                        VStack(spacing: 10) {
                            Text("当星光缀满夜空，\n繁花绽放中央，\n藤蔓萦碧延展，")

                            Text("感谢您用每一次互动，\n让这座心之秘境生长成了最温柔的模样。")
                        }
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Text("您现在可以将iPad交还给子女")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.35), radius: 3, x: 0, y: 2)
                            .padding(.top, 4)

                        Button(action: onClose) {
                            Text("我知道了")
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

// MARK: - 纯实心卡片：边缘“没有硬线”，不发光（local）
private struct MGSoftEdgeSolidCardBackground: View {
    let cornerRadius: CGFloat
    let feather: CGFloat
    let featherBlur: CGFloat
    let fill: Color

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        ZStack {
            // 1) 底层：完整实心填充
            shape
                .fill(fill)

            // 2) 内层：把中心补回 100% 不透明
            shape
                .inset(by: max(0, feather - 4))
                .fill(fill)
        }
        .compositingGroup()

        // 3) 只羽化 alpha（mask），不 blur 颜色，所以不会“发光”。
        .mask(
            shape
                .fill(Color.white)
                .blur(radius: featherBlur)
        )

        // 4) 保留一点层级阴影
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

                        Text("今日的互动已全部完成")
                            .font(.system(size: 20, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                            .shadow(color: Color.black.opacity(0.55), radius: 6, x: 0, y: 2)

                        Color.clear.frame(height: 18)

                        Text("现在，您可以查看今日的心灵报告。")
                            .font(.system(size: 25, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.86))
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .shadow(color: Color.black.opacity(0.45), radius: 5, x: 0, y: 2)

                        Color.clear.frame(height: 22)

                        Button(action: onClose) {
                            Text("我知道了")
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


