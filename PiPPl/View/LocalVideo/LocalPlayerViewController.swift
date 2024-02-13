//
//  LocalPlayerViewController.swift
//  PiPPl
//
//  Created by 김민택 on 1/19/24.
//

import AVKit
import Photos
import UIKit

class LocalPlayerViewController: UIViewController {

    // MARK: - Property

    private let videoPlayer = LocalVideoPlayer.shared
    private lazy var pipController = AVPictureInPictureController(playerLayer: videoPlayer.playerLayer)
    private let buttonConfig = UIButton.Configuration.plain()
    private var asset = PHAsset()

    // MARK: - View

    private let videoView: UIView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UIView())

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.isToolbarHidden = false

        videoPlayer.configureVideo(asset)
        pipController?.delegate = self

        layout()
        configureNavigationItem()
        configureToolbarItem()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewDidAppear(_ animated: Bool) {
        videoPlayer.play()
    }

    override func viewWillDisappear(_ animated: Bool) {
        videoPlayer.pause()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        videoView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        videoPlayer.playerLayer.frame = videoView.bounds
    }

    // MARK: - Method

    private func layout() {
        view.addSubview(videoView)

        videoView.frame = view.bounds
        videoView.layer.addSublayer(videoPlayer.playerLayer)
        videoPlayer.playerLayer.frame = videoView.bounds
        videoPlayer.playerLayer.videoGravity = .resizeAspect
    }

    private func configureNavigationItem() {
        navigationItem.title = PHAssetResource.assetResources(for: asset).first?.originalFilename

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "pip.enter"), primaryAction: UIAction { _ in
            self.pipController?.stopPictureInPicture()
            self.pipController?.startPictureInPicture()
        })
    }

    private func configureToolbarItem() {
        let progressView: ToolbarProgressView = {
            $0.progressViewStyle = .bar
            $0.progress = 0.0
            $0.backgroundColor = .lightGray
            $0.translatesAutoresizingMaskIntoConstraints = false
            return $0
        }(ToolbarProgressView())

        let slider: UISlider = {
            $0.value = 0.0
            $0.thumbTintColor = .clear
            $0.frame = CGRect(x: 0, y: 0, width: 0, height: 32)
            $0.translatesAutoresizingMaskIntoConstraints = false
            return $0
        }(UISlider())

        slider.addAction(UIAction { _ in LocalVideoPlayer.shared.pause() }, for: .touchDown)
        slider.addAction(UIAction { _ in LocalVideoPlayer.shared.changePlayingFrame(Double(slider.value)) }, for: .valueChanged)
        slider.addAction(UIAction { _ in LocalVideoPlayer.shared.play() }, for: .touchUpInside)
        slider.addAction(UIAction { _ in LocalVideoPlayer.shared.play() }, for: .touchUpOutside)

        let playAndPauseButton = UIButton(configuration: buttonConfig, primaryAction: UIAction { _ in
            self.videoPlayer.status == .paused ? self.videoPlayer.play() : self.videoPlayer.pause()
        })

        playAndPauseButton.configuration?.image = UIImage(systemName: self.videoPlayer.status == .paused ? "pause.fill" : "play.fill")

        playAndPauseButton.configurationUpdateHandler = { btn in
            switch btn.state {
            case .highlighted:
                btn.configuration?.image = UIImage(systemName: self.videoPlayer.status == .paused ? "pause.fill" : "play.fill")
            default:
                break
            }
        }

        let forwardButton = UIButton(configuration: buttonConfig, primaryAction: UIAction { _ in self.videoPlayer.playForward(Double(slider.value)) })
        forwardButton.configuration?.image = UIImage(systemName: "forward.fill")

        videoPlayer.addPeriodicTimeObserver { seconds, durationSeconds in
            progressView.progress = Float(seconds / durationSeconds)
            slider.value = Float(seconds / durationSeconds)

            if seconds == durationSeconds {
                playAndPauseButton.configuration?.image = UIImage(systemName: "play.fill")
                self.videoPlayer.pause()
                self.videoPlayer.changePlayingFrame(0)
            }
        }

        let backwardButton = UIButton(configuration: buttonConfig, primaryAction: UIAction { _ in self.videoPlayer.playBackward(Double(slider.value)) })
        backwardButton.configuration?.image = UIImage(systemName: "backward.fill")

//        navigationController?.toolbar.addSubview(progressView)
//        NSLayoutConstraint.activate([
//            progressView.bottomAnchor.constraint(equalTo: navigationController!.toolbar.topAnchor),
//            progressView.leftAnchor.constraint(equalTo: navigationController!.toolbar.leftAnchor),
//            progressView.rightAnchor.constraint(equalTo: navigationController!.toolbar.rightAnchor),
//            progressView.heightAnchor.constraint(equalToConstant: 8)
//        ])

        navigationController?.toolbar.addSubview(slider)
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: navigationController!.toolbar.topAnchor, constant: -16),
            slider.leftAnchor.constraint(equalTo: navigationController!.toolbar.leftAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: navigationController!.toolbar.topAnchor, constant: 16),
            slider.rightAnchor.constraint(equalTo: navigationController!.toolbar.rightAnchor, constant: 16),
            slider.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.toolbarItems = [.flexibleSpace(), UIBarButtonItem(customView: backwardButton), .flexibleSpace(), UIBarButtonItem(customView: playAndPauseButton), .flexibleSpace(), UIBarButtonItem(customView: forwardButton), .flexibleSpace()]
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationController?.isToolbarHidden.toggle()
        navigationController?.isNavigationBarHidden.toggle()
    }

    func configureVideo(_ asset: PHAsset) {
        self.asset = asset
    }

}

extension LocalPlayerViewController: AVPictureInPictureControllerDelegate {}

class ToolbarProgressView: UIProgressView {

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        progress = Float(touches.first!.location(in: self).x / self.bounds.width)
        LocalVideoPlayer.shared.changePlayingFrame(Double(progress))
    }

}
