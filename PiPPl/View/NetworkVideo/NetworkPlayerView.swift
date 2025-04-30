//
//  NetworkPlayerView.swift
//  PiPPl
//
//  Created by 김민택 on 5/23/24.
//

import SwiftUI
import WebKit

struct NetworkPlayerView: View {
    let webView = WebView()

    var body: some View {
        webView
            .onDisappear {
                webView.pauseVideo()
            }
    }
}

struct WebView: UIViewControllerRepresentable {
    let networkPlayerView = NetworkPlayerViewController()

    func makeUIViewController(context: Context) -> UIViewController {
        return UINavigationController(rootViewController: networkPlayerView)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}

    func pauseVideo() {
        networkPlayerView.pauseVideo()
    }
}

#Preview {
    NetworkPlayerView()
}
