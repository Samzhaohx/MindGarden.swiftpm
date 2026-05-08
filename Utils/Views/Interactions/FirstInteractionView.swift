import SwiftUI
import RealityKit
import ARKit
import Combine
import UIKit
import AVFoundation

// MARK: - Step state

enum StarStep: Equatable {
    case poeticIntro      // Step 1: Poetic intro
    case instruction      // Step 2: Instruction
    case searching(index: Int)
    case found(index: Int)
    case finished
}

// MARK: - SwiftUI shell

struct FirstInteractionView: View {

    /// Called when exiting after completion
    let onFinishedReturn: (() -> Void)?

    /// External close action
    let onClose: () -> Void

    init(onFinishedReturn: (() -> Void)? = nil, onClose: @escaping () -> Void) {
        self.onFinishedReturn = onFinishedReturn
        self.onClose = onClose
    }

    @State private var step: StarStep = .poeticIntro
    @State private var currentTargetIndex: Int = 1
    @State private var targetFound: Bool = false
    
    //
    @State private var showHelp: Bool = false

    // Metrics Timer: pause on modals; stop on 3rd star found
    @State private var starsTimingStart: Date? = nil
    @State private var starsPauseBegan: Date? = nil
    @State private var starsPausedTotal: TimeInterval = 0
    @State private var starsFinalTimeS: Double? = nil

    private func startStarsTiming() {
        starsTimingStart = Date()
        starsPauseBegan = nil
        starsPausedTotal = 0
        starsFinalTimeS = nil
    }

    private func pauseStarsTiming() {
        guard starsTimingStart != nil, starsFinalTimeS == nil, starsPauseBegan == nil else { return }
        starsPauseBegan = Date()
    }

    private func resumeStarsTimingIfNeeded() {
        guard starsTimingStart != nil, starsFinalTimeS == nil, let p = starsPauseBegan else { return }
        starsPausedTotal += Date().timeIntervalSince(p)
        starsPauseBegan = nil
    }

    private func finishStarsTimingIfNeeded() {
        guard starsFinalTimeS == nil, let start = starsTimingStart else { return }
        //
        if let p = starsPauseBegan {
            starsPausedTotal += Date().timeIntervalSince(p)
            starsPauseBegan = nil
        }
        starsFinalTimeS = max(0, Date().timeIntervalSince(start) - starsPausedTotal)
    }

    @AppStorage("bgmOn") private var bgmOn: Bool = true
    
    var body: some View {
        ZStack {
            StarARView(
                currentTargetIndex: $currentTargetIndex,
                targetFound: $targetFound
            )
            .ignoresSafeArea()

            //
            //
            if !showHelp {
                overlayUI
                    .animation(.smooth(duration: 0.35), value: step)
                    .transition(.opacity)
            }

            //
            if showHelp {
                HelpCard {
                    withAnimation(.smooth(duration: 0.3)) {
                        showHelp = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(100) //
            }

            //
            VStack {
                HStack {
                    //
                    GlassIconButton(
                        systemName: "chevron.left",
                        action: { onClose() }
                    )
                    .padding(.leading, 20)
                    .padding(.top, 16)

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
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .contentTransition(
                                .symbolEffect(.replace.magic(fallback: .downUp.wholeSymbol), options: .nonRepeating)
                            )
                            .frame(width: 32, height: 32)
                    }
                    .mgGlassButtonStyleCompat()
                    .tint(.white.opacity(0.9))
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.trailing, 5)
                    .padding(.top, 16)
                    
                    //
                    GlassIconButton(
                        systemName: "questionmark",
                        action: {
                            withAnimation(.smooth(duration: 0.3)) {
                                showHelp = true
                            }
                        }
                    )
                    .padding(.trailing, 20)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .onChange(of: targetFound) { _, newValue in
            guard newValue else { return }
            if case .searching(let idx) = step {
                if idx >= 3 {
                    // Metrics Timer: stop on 3rd star found
                    finishStarsTimingIfNeeded()
                } else {
                    // Metrics Timer: pause during modal
                    pauseStarsTiming()
                }

                withAnimation(.smooth(duration: 0.35)) {
                    step = .found(index: idx)
                }
            }
        }
        .onChange(of: showHelp) { _, isShowing in
            if isShowing {
                // Metrics Timer: pause on help overlay
                pauseStarsTiming()
            } else {
                // Resume only in Searching mode
                if case .searching = step {
                    resumeStarsTimingIfNeeded()
                }
            }
        }
    }

    // MARK: - UI by step

    @ViewBuilder
    private var overlayUI: some View {
        switch step {
            
        case .poeticIntro:
            PoeticIntroCard {
                withAnimation(.smooth(duration: 0.35)) {
                    step = .instruction
                }
            }
            .transition(.opacity)

        case .instruction:
            InstructionCard {
                startStarsTiming()
                currentTargetIndex = 1
                targetFound = false
                withAnimation(.smooth(duration: 0.35)) {
                    step = .searching(index: 1)
                }
            }
            .transition(.opacity)

        case .searching(let idx):
            SearchingHUD(index: idx)
                .transition(.opacity)

        case .found(let idx):
            FoundCard(index: idx) {
                if idx < 3 {
                    resumeStarsTimingIfNeeded()
                    let next = idx + 1
                    currentTargetIndex = next
                    targetFound = false
                    withAnimation(.smooth(duration: 0.35)) {
                        step = .searching(index: next)
                    }
                } else {
                    withAnimation(.smooth(duration: 0.35)) {
                        step = .finished
                    }
                }
            }
            .transition(.opacity)

        case .finished:
            FinishedCard(
                timeS: starsFinalTimeS,
                onReplay: {
                    startStarsTiming()
                    currentTargetIndex = 1
                    targetFound = false
                    withAnimation(.smooth(duration: 0.35)) {
                        step = .searching(index: 1)
                    }
                },
                onExit: {
                    // Ensure final timing (safety)
                    finishStarsTimingIfNeeded()
                    if let t = starsFinalTimeS {
                        MindGardenMetricsStore.shared.recordStars(timeS: t)
                    }
                    onFinishedReturn?()
                    onClose()
                }
            )
            .transition(.opacity)
        }
    }
}


private struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(32)
            .frame(width: 520, height: 420) // Keep the previous size
            .applyCardGlassCompat()
            .shadow(color: .black.opacity(0.25),
                    radius: 18, x: 0, y: 10)
    }
}

private struct GlassPill<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .font(.subheadline)
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .applyPillGlassCompat()
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 6)
    }
}

private extension View {

    @ViewBuilder
    func applyCardGlassCompat() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .clear.interactive(),
                in: .rect(cornerRadius: 28)
            )
        } else {
            self.mgGlassEffectCompat(in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }

    @ViewBuilder
    func applyPillGlassCompat() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular.interactive(),
                in: .capsule
            )
        } else {
            self.mgGlassEffectCompat(in: Capsule(style: .continuous))
        }
    }
}

private struct GlassTextButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 22)
                .padding(.vertical, 9)
        }
        .mgGlassButtonStyleCompat()
        .tint(.white.opacity(0.9))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 1)
        )
    }
}

private struct GlassIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
        }
        .mgGlassButtonStyleCompat()
        .tint(.white.opacity(0.9))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - HUD

private struct RotateIpadIcon: View {
    var body: some View {
        VStack(spacing: 1) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 20, weight: .semibold))

            Image(systemName: "ipad.landscape")
                .font(.system(size: 35, weight: .regular))
        }
        .symbolRenderingMode(.monochrome)
        .foregroundStyle(.secondary)
    }
}

private struct HelpCard: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            GlassCard {
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        VStack(spacing: 12) {
                            Text("About this activity")
                                .font(.title3.bold())
                            
                            Text("A small exercise using AR.\nTurn your body in real space\nto find hidden virtual stars.")
                            
                            Text("It helps train spatial memory\nand attention.")
                                .foregroundStyle(.white.opacity(0.7))
                                .font(.footnote)
                        }
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .foregroundStyle(.white)
                    }
                    
                    Spacer()
                    
                    GlassTextButton(title: "Got it.", action: onDismiss)
                    
                    Spacer()
                }
            }
        }
    }
}

private struct PoeticIntroCard: View {
    let onNext: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(.yellow.opacity(0.8))
                    
                    VStack(spacing: 12) {
                        Text("Memory can be like a star—\nnot gone, just dim for a while")
                        Text("Stay with the sky a little longer,\nand it may brighten")
                        Text("Attention is the same.\nGo slowly.\nMany small pieces are still there")
                    }
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                }
                .mgGlassButtonStyleCompat()
                .tint(.white.opacity(0.9))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }
}

private struct InstructionCard: View {
    let onStart: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 0) {
                Spacer()
                
                Text("Look at tonight's sky")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                
                Color.clear.frame(height: 60)
                
                VStack(spacing: 12) {
                    Text("Find three special stars, one by one.\nThey are waiting to be lit.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(spacing: 10) {
                        RotateIpadIcon()
                        
                        VStack(spacing: 4) {
                            #if targetEnvironment(simulator)
                            Text("Swipe the screen slowly,")
                            Text("keep the star at the center. Let the glow guide you.")
                            #else
                            Text("Hold the iPad level and turn slowly,")
                            Text("keep the star at the center. Let the glow guide you.")
                            #endif
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top, 25)
                }
                .foregroundStyle(.white)
                
                Color.clear.frame(height: 40)
                
                GlassTextButton(title: "Start", action: onStart)
                
                Spacer()
            }
        }
    }
}

private struct SearchingHUD: View {
    let index: Int

    var body: some View {
        VStack {
            GlassPill {
                VStack(spacing: 4) {
                    Text("Find star \(index) in the night sky")
                        .font(.headline)

                    Text(searchingText(for: index))
                        .font(.subheadline)
                }
                .foregroundStyle(.white)
            }
            .padding(.top, 16)

            Spacer()
        }
        .padding(.horizontal)
    }

    private func searchingText(for index: Int) -> String {
        switch index {
        case 1:
            return "Turn the iPad slowly. Find the star that softly breathes."
        case 2:
            return "The second star is on your right."
        case 3:
            return "The last star is also on your right. No rush."
        default:
            return ""
        }
    }
}

private struct FoundCard: View {
    let index: Int
    let onNext: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text(foundTitle(for: index))
                        .font(.headline)
                    
                    Text(foundText(for: index))
                        .font(.body)
                        .multilineTextAlignment(.center)
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                if index < 3 {
                    GlassTextButton(title: "Next star", action: onNext)
                } else {
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                    }
                    .mgGlassButtonStyleCompat()
                    .tint(.white.opacity(0.9))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func foundTitle(for index: Int) -> String {
        switch index {
        case 1: return "You found the first star"
        case 2: return "The second star is here"
        case 3: return "You found the third star"
        default: return ""
        }
    }

    private func foundText(for index: Int) -> String {
        switch index {
        case 1:
            return "Thank you for looking up at the night sky."
        case 2:
            return "Your patience will be remembered by the sky."
        case 3:
            return "You found all the stars."
        default:
            return ""
        }
    }
}

private struct FinishedCard: View {
    let timeS: Double?
    let onReplay: () -> Void
    let onExit: () -> Void

    var body: some View {
        GlassCard {
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 18) {
                    Text("The sky thanks your gaze")
                        .font(.headline)
                    
                    Text("""
Memory and attention are like stars.
Sometimes dim, sometimes bright.
No matter the glow,
what matters is having someone beside you.
""")
                    .font(.body)
                    .multilineTextAlignment(.center)

                }
                .foregroundStyle(.white)
                
                Spacer()
                
                HStack(spacing: 16) {
                    GlassTextButton(title: "Replay", action: onReplay)
                    GlassTextButton(title: "Back to garden", action: onExit)
                }
            }
        }
    }
}


struct StarARView: UIViewRepresentable {
    @Binding var currentTargetIndex: Int
    @Binding var targetFound: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARView {
        #if targetEnvironment(simulator)
        let arView = ARView(
            frame: .zero,
            cameraMode: .nonAR,
            automaticallyConfigureSession: false
        )
        // Keep a consistent dark backdrop behind the sky cube.
        arView.environment.background = .color(.black)

        context.coordinator.arView = arView
        context.coordinator.isSimulatorMode = true
        context.coordinator.ensureRootAnchor()
        context.coordinator.setupSkyPanels()
        context.coordinator.setupStars()
        context.coordinator.installPanGestureIfNeeded()
        context.coordinator.configureSimulatorCameraIfNeeded()
        context.coordinator.startUpdateLoop()
        return arView
        #else
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )

        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        arView.session.run(config)

        // Keep a consistent dark backdrop behind the sky cube.
        arView.environment.background = .color(.black)

        context.coordinator.arView = arView
        context.coordinator.isSimulatorMode = false
        context.coordinator.ensureRootAnchor()
        context.coordinator.setupSkyPanels()
        context.coordinator.setupStars()
        context.coordinator.startUpdateLoop()

        return arView
        #endif
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        context.coordinator.currentTargetIndex = currentTargetIndex
        context.coordinator.updateTargetVisibility()
    }

    @MainActor
    class Coordinator {
        var parent: StarARView
        weak var arView: ARView?

        var isSimulatorMode: Bool = false
        private var rootAnchor: AnchorEntity?
        private var cameraAnchor: AnchorEntity?
        private var simulatorCamera: PerspectiveCamera?

        // Manual view control (simulator)
        private var yaw: Float = 0
        private var pitch: Float = 0
        private var lastPanTranslation: CGPoint = .zero

        var stars: [ModelEntity] = []
        var glowStars: [ModelEntity] = []

        var currentTargetIndex: Int = 1
        var updateSubscription: (any Cancellable)?
        var breathingTime: TimeInterval = 0

        var focusTime: TimeInterval = 0
        var focusProgress: Double = 0

        init(_ parent: StarARView) {
            self.parent = parent
        }

        func ensureRootAnchor() {
            guard let arView else { return }
            if rootAnchor == nil {
                let root = AnchorEntity(world: .zero)
                arView.scene.addAnchor(root)
                rootAnchor = root
            }
        }

        func installPanGestureIfNeeded() {
            guard isSimulatorMode, let arView else { return }
            // Avoid adding multiple recognizers if SwiftUI recreates the view.
            if (arView.gestureRecognizers ?? []).contains(where: { $0 is UIPanGestureRecognizer }) {
                return
            }
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            arView.addGestureRecognizer(pan)
        }

        func configureSimulatorCameraIfNeeded() {
            guard isSimulatorMode, let arView else { return }
            // Only configure once.
            if simulatorCamera != nil { return }

            // Create a dedicated camera anchor at the origin.
            let camAnchor = AnchorEntity(world: .zero)
            let camera = PerspectiveCamera()

            // Narrower FOV = less "wide angle" (stars appear larger and easier to see).
            camera.camera.fieldOfViewInDegrees = 45

            // Place camera at the center of the sky cube.
            camera.position = .zero

            camAnchor.addChild(camera)
            arView.scene.addAnchor(camAnchor)

            cameraAnchor = camAnchor
            simulatorCamera = camera
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard isSimulatorMode, let arView, let rootAnchor else { return }

            let t = gesture.translation(in: arView)
            let dx = Float(t.x - lastPanTranslation.x)
            let dy = Float(t.y - lastPanTranslation.y)
            lastPanTranslation = t

            // Sensitivity tuned for trackpad/mouse on simulator.
            let sensitivity: Float = 0.005
            yaw += dx * sensitivity
            pitch += dy * sensitivity

            // Clamp pitch to avoid flipping.
            pitch = max(min(pitch, 1.0), -1.0)

            let qYaw = simd_quatf(angle: yaw, axis: [0, 1, 0])
            let qPitch = simd_quatf(angle: pitch, axis: [1, 0, 0])
            rootAnchor.transform.rotation = simd_mul(qYaw, qPitch)

            if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
                lastPanTranslation = .zero
            }
        }

        func setupSkyPanels() {
            guard let arView else { return }

            guard let texture = try? TextureResource.load(named: "StarSkyBackground") else {
                print("❌ SkyPanel texture load failed")
                return
            }

            var material = UnlitMaterial()
            material.color = .init(
                tint: .white,
                texture: .init(texture)
            )
            material.faceCulling = .none

            let distance: Float = 75.0
            let size: Float = 150.0

            let planeMesh = MeshResource.generatePlane(width: size, height: size)
            ensureRootAnchor()
            guard let rootAnchor else { return }

            let front = ModelEntity(mesh: planeMesh, materials: [material])
            front.position = SIMD3<Float>(0, 0, -distance)

            let back = ModelEntity(mesh: planeMesh, materials: [material])
            back.position = SIMD3<Float>(0, 0, distance)
            back.transform.rotation = simd_quatf(angle: .pi, axis: [0, 1, 0])

            let right = ModelEntity(mesh: planeMesh, materials: [material])
            right.position = SIMD3<Float>(distance, 0, 0)
            right.transform.rotation = simd_quatf(angle: -.pi/2, axis: [0, 1, 0])

            let left = ModelEntity(mesh: planeMesh, materials: [material])
            left.position = SIMD3<Float>(-distance, 0, 0)
            left.transform.rotation = simd_quatf(angle: .pi/2, axis: [0, 1, 0])

            let top = ModelEntity(mesh: planeMesh, materials: [material])
            top.position = SIMD3<Float>(0, distance, 0)
            top.transform.rotation = simd_quatf(angle: .pi/2, axis: [1, 0, 0])

            let bottom = ModelEntity(mesh: planeMesh, materials: [material])
            bottom.position = SIMD3<Float>(0, -distance, 0)
            bottom.transform.rotation = simd_quatf(angle: -.pi/2, axis: [1, 0, 0])

            rootAnchor.addChild(front)
            rootAnchor.addChild(back)
            rootAnchor.addChild(right)
            rootAnchor.addChild(left)
            rootAnchor.addChild(top)
            rootAnchor.addChild(bottom)
        }


        func setupStars() {
            guard let arView else { return }
            ensureRootAnchor()
            guard let rootAnchor else { return }

            let planeSize: Float = 0.18
            let planeMesh = MeshResource.generatePlane(width: planeSize, height: planeSize)

            var texture: TextureResource?
            do {
                if let uiImage = UIImage(named: "StarIcon"),
                   let cgImage = uiImage.cgImage {
                    let options = TextureResource.CreateOptions(
                        semantic: .color,
                        mipmapsMode: .none
                    )
                    texture = try TextureResource(
                        image: cgImage,
                        withName: "StarIcon",
                        options: options
                    )
                } else {
                    print("❌ StarIcon image missing or CGImage creation failed")
                }
            } catch {
                print("❌ Failed to build StarIcon texture from UIImage: \(error)")
            }

            let warmYellow = UIColor(Color.FCEDE2)

            var coreMat = UnlitMaterial()
            var glowMat = UnlitMaterial()

            if let texture {
                coreMat.color = .init(
                    tint: warmYellow,
                    texture: .init(texture)
                )

                glowMat.color = .init(
                    tint: warmYellow.withAlphaComponent(0.25),
                    texture: .init(texture)
                )
            } else {
                coreMat.color = .init(tint: warmYellow)
                glowMat.color = .init(tint: warmYellow.withAlphaComponent(0.25))
            }

            coreMat.blending = .transparent(opacity: .init(scale: 1.0))
            coreMat.opacityThreshold = 0.01
            coreMat.faceCulling = .none

            glowMat.blending = .transparent(opacity: .init(scale: 1.0))
            glowMat.opacityThreshold = 0.01
            glowMat.faceCulling = .none

            let distances: [Float] = [1.6, 1.6, 2.0]
            let yawAngles: [Float] = [
                -.pi / 6,
                .pi / 3,
                .pi
            ]

            for i in 0..<3 {
                let core = ModelEntity(mesh: planeMesh, materials: [coreMat])
                let glow = ModelEntity(mesh: planeMesh, materials: [glowMat])

                glow.scale = SIMD3<Float>(repeating: 1.0)

                let d = distances[i]
                let yaw = yawAngles[i]
                let x = d * sin(yaw)
                let z = -d * cos(yaw)
                let position = SIMD3<Float>(x, 0, z)

                let holder = Entity()
                holder.position = position
                holder.addChild(glow)
                holder.addChild(core)
                rootAnchor.addChild(holder)

                glow.components.set(BillboardComponent())
                core.components.set(BillboardComponent())

                stars.append(core)
                glowStars.append(glow)
            }

            updateTargetVisibility()
        }

        func updateTargetVisibility() {
            guard !stars.isEmpty, stars.count == glowStars.count else { return }

            for i in 0..<stars.count {
                let isActive = (i == currentTargetIndex - 1)
                stars[i].isEnabled = isActive
                glowStars[i].isEnabled = isActive
            }

            focusTime = 0
            focusProgress = 0
        }


        func startUpdateLoop() {
            guard let arView else { return }

            updateSubscription = arView.scene.subscribe(
                to: SceneEvents.Update.self
            ) { [weak self] event in
                self?.handleUpdate(event: event)
            }
        }

        func handleUpdate(event: SceneEvents.Update) {
            updateBreathing(deltaTime: event.deltaTime)

            guard let arView,
                  currentTargetIndex >= 1,
                  currentTargetIndex <= stars.count else { return }

            let star = stars[currentTargetIndex - 1]

            let worldPos = star.position(relativeTo: nil)
            guard let screenPoint = arView.project(worldPos) else { return }

            let bounds = arView.bounds
            let center = CGPoint(x: bounds.midX, y: bounds.midY)

            let dx = screenPoint.x - center.x
            let dy = screenPoint.y - center.y
            let distance = sqrt(dx * dx + dy * dy)

            let threshold: CGFloat = min(bounds.width, bounds.height) * 0.12
            let requiredFocusDuration: Double = 1.5

            if distance < threshold {
                focusTime += event.deltaTime
                focusProgress = min(focusTime / requiredFocusDuration, 1.0)

                if focusProgress >= 1.0, parent.targetFound == false {
                    parent.targetFound = true
                }
            } else {
                focusTime = 0
                focusProgress = 0
            }
        }

        private func updateBreathing(deltaTime: TimeInterval) {
            breathingTime += deltaTime

            let period: Double = 3.0
            let phase = (breathingTime.truncatingRemainder(dividingBy: period)) / period
            let t = 0.5 - 0.5 * cos(phase * 2 * .pi)

            let baseAlpha: Double = 0.18 + 0.22 * t

            let baseScale: Float = 1.0
            let breathingScale = baseScale + 0.25 * Float(t)

            let extraScaleMax: Float = 0.9
            let focusFactor = 1.0 + extraScaleMax * Float(focusProgress)

            let tintBase = UIColor(Color.FCEDE2)

            for (index, glow) in glowStars.enumerated() {
                var finalScale = breathingScale
                var alpha = baseAlpha

                if index == currentTargetIndex - 1 {
                    finalScale *= focusFactor

                    let brightnessBoost = 1.0 + 0.8 * focusProgress
                    alpha = min(baseAlpha * brightnessBoost, 1.0)
                }

                glow.scale = SIMD3<Float>(repeating: finalScale)

                guard var model = glow.model,
                      !model.materials.isEmpty,
                      var unlit = model.materials[0] as? UnlitMaterial
                else { continue }

                let oldTexture = unlit.color.texture
                let tint = tintBase.withAlphaComponent(CGFloat(alpha))

                unlit.color = .init(
                    tint: tint,
                    texture: oldTexture
                )

                model.materials[0] = unlit
                glow.model = model
            }
        }
    }
}
 
