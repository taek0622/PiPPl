//
//  LocalVideoPlayView.swift
//  PiPPl
//
//  Created by 김민택 on 5/1/24.
//

import AVKit
import Photos
import SwiftUI

struct LocalVideoPlayView: View {
    var asset: PHAsset
    var body: some View {
            LocalPlayerView(player: LocalVideoPlayer.shared.player)
        ZStack {
        }
        .onAppear {
            LocalVideoPlayer.shared.configureVideo(asset)
        }
        .onDisappear {
            LocalVideoPlayer.shared.pause()
        }
    }
}

struct LocalPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> LocalPlayerViewController {
        let playerView = LocalPlayerViewController()
        playerView.player = player
        return playerView
    }

    func updateUIViewController(_ uiViewController: LocalPlayerViewController, context: Context) {}
}

#Preview {
    NavigationView {
        LocalVideoPlayView(asset: PHAsset())
    }
}
