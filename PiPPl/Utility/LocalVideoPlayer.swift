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

    var status: AVPlayer.TimeControlStatus {
        player.timeControlStatus
    }

    // MARK: - Method

    func configureVideo(_ asset: PHAsset) async {
        await MainActor.run {
            self.videoLoadProgress = 0
            self.isVideoLoading = true
        }

        do {
            let playerItem = try await requestPlayerItem(asset: asset)

            await MainActor.run {
                self.player.replaceCurrentItem(with: playerItem)

                let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
                timer.schedule(deadline: .now(), repeating: 0.05)
                timer.setEventHandler { [weak self] in
                    guard let self else { return }

                    if self.videoLoadProgress <= 0.96 {
                        self.videoLoadProgress += 0.01
                    } else {
                        timer.cancel()
                    }
                }
                timer.resume()

                self.statusCancellable = playerItem.publisher(for: \.status)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] status in
                        if status == .readyToPlay {
                            timer.cancel()
                            self?.videoLoadProgress = 1.0
                            self?.isVideoLoading = false
                            self?.player.play()
                        }
                    }
            }
        } catch {
            await MainActor.run {
                self.isVideoLoading = false
            }
        }
    }

    func requestPlayerItem(asset: PHAsset) async throws -> AVPlayerItem {
        try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.version = .original
            options.deliveryMode = .highQualityFormat
            options.progressHandler = { progress, _, _, _ in
                Task { @MainActor in
                    self.videoLoadProgress = Double(progress) * 0.2
                }
            }

            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options) { playerItem, info in
                if let item = playerItem {
                    continuation.resume(returning: item)
                } else {
                    continuation.resume(throwing: NSError(domain: "VideoLoad", code: 0))
                }
            }
        }
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
