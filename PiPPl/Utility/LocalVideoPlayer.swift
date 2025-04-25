//
//  LocalVideoPlayer.swift
//  PiPPl
//
//  Created by 김민택 on 1/19/24.
//

import AVFoundation
import Photos

class LocalVideoPlayer {

    // MARK: - Property

    static let shared = LocalVideoPlayer()

    lazy var player: AVPlayer = {
        $0.actionAtItemEnd = .pause
        return $0
    }(AVPlayer())

    lazy var playerLayer = AVPlayerLayer(player: player)

    var status: AVPlayer.TimeControlStatus {
        player.timeControlStatus
    }

    // MARK: - Initializer

    private init() {}

    // MARK: - Method

    func configureVideo(_ asset: PHAsset) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.version = .original
        option.deliveryMode = .highQualityFormat

        PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { playerItem, info in
            self.player.replaceCurrentItem(with: playerItem)
        }
    }

    func play() {
        player.play()
    }

    func pause() {
        player.pause()
    }

    func addPeriodicTimeObserver(closurePerInterval: @escaping (Double, Double) -> Void) {
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        player.addPeriodicTimeObserver(forInterval: time, queue: .main) { progressTime in
            let seconds = CMTimeGetSeconds(progressTime)
            guard let duration = self.player.currentItem?.duration.seconds else { return }

            if !duration.isNaN {
                closurePerInterval(seconds, duration)
            }
        }
    }

    func changePlayingFrame(_ playingProgress: Double) {
        guard let duration = self.player.currentItem?.duration.seconds else { return }
        player.seek(to: CMTime(value: CMTimeValue(duration * playingProgress), timescale: 1))
    }

    func playForward(_ playingProgress: Double) {
        guard let duration = self.player.currentItem?.duration.seconds else { return }
        let chaingingTime = CMTimeAdd(CMTime(value: CMTimeValue(duration * playingProgress), timescale: 1), CMTime(value: 10, timescale: 1))
        player.seek(to: chaingingTime)
    }

    func playBackward(_ playingProgress: Double) {
        guard let duration = self.player.currentItem?.duration.seconds else { return }
        let chaingTime = CMTimeSubtract(CMTime(value: CMTimeValue(duration * playingProgress), timescale: 1), CMTime(value: 10, timescale: 1))
        player.seek(to: chaingTime)
    }

}
