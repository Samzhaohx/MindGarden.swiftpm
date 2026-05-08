import AVFoundation
import UIKit

@MainActor
final class BGMPlayer {
    static let shared = BGMPlayer()

    private var player: AVAudioPlayer?

    func startLoopFromDataAsset(named assetName: String, volume: Float = 0.35) {
        if player?.isPlaying == true { return }

        guard let asset = NSDataAsset(name: assetName) else {
            print("❌ NSDataAsset not found: \(assetName)")
            return
        }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(assetName).mp3")

        do {
            try asset.data.write(to: tmpURL, options: .atomic)

            try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let p = try AVAudioPlayer(contentsOf: tmpURL)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            p.play()

            player = p
        } catch {
            print("❌ BGM start failed:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func setVolume(_ v: Float) {
        player?.volume = max(0, min(1, v))
    }
}

