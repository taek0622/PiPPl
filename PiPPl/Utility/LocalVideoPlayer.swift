//
//  LocalVideoPlayer.swift
//  PiPPl
//
//  Created by 김민택 on 1/19/24.
//

import AVFoundation
import Combine
import Photos

class LocalVideoPlayer: ObservableObject {

    // MARK: - Property

    @Published var isVideoLoading = false
    @Published var videoLoadProgress: Double = 0.0
    private var statusCancellable: AnyCancellable?

    lazy var player: AVPlayer = {
        $0.actionAtItemEnd = .pause
        return $0
    }(AVPlayer())

    lazy var playerLayer = AVPlayerLayer(player: player)

    var status: AVPlayer.TimeControlStatus {
        player.timeControlStatus
    }

    // MARK: - Method

    func configureVideo(_ asset: PHAsset) {
        let option = PHVideoRequestOptions()
        option.isNetworkAccessAllowed = true
        option.version = .original
        option.deliveryMode = .highQualityFormat
        self.isVideoLoading = true
        self.videoLoadProgress = 0.0

        option.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.async {
                self.videoLoadProgress = Double(progress)
            }
        }

        PHImageManager.default().requestPlayerItem(forVideo: asset, options: option) { playerItem, info in
            guard let playerItem else { return }
            self.player.replaceCurrentItem(with: playerItem)

            self.statusCancellable = playerItem.publisher(for: \.status)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] status in
                    if status == .readyToPlay {
                        self?.isVideoLoading = false
                        self?.play()
                    }
                }
        }

    }

    func play() {
        player.play()
    }

    func pause() {
        self.player.replaceCurrentItem(with: nil)
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

}
