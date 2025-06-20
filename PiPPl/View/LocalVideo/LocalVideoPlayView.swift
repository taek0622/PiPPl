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
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.isPresented) var isPresented
    @StateObject private var localVideoPlayer = LocalVideoPlayer()

    var asset: PHAsset

    var body: some View {
        ZStack {
            LocalPlayerView(player: localVideoPlayer.player)

            if localVideoPlayer.isVideoLoading {
                Color(colorScheme == .light ? #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1) : #colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1))
                Color(colorScheme == .light ? #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 0.82) : #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 0.82))
                VStack {
                    HStack {
                        Text(AppText.videoLoadText)
                        Spacer()
                        Text("\(Int(localVideoPlayer.videoLoadProgress * 100))%")
                    }
                    ProgressView(value: localVideoPlayer.videoLoadProgress)
                }
                .padding()
                .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? UIScreen.main.bounds.width : UIScreen.main.bounds.width / 5 * 3)
            }
        }
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                VStack {
                    Text(asset.creationDate ?? Date.now, style: .date)
                        .font(.system(size: 15, weight: .semibold))
                    Text(asset.creationDate ?? Date.now, style: .time)
                        .foregroundStyle(.gray)
                        .font(.system(size: 12))
                }
            }
        })
        .onAppear {
            if !isPresented {
                Task {
                    await localVideoPlayer.configureVideo(asset)
                }
            }
        }
        .onDisappear {
            if !isPresented {
                localVideoPlayer.pause()
            }
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
