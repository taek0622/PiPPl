//
//  NetworkPlayerView.swift
//  PiPPl
//
//  Created by 김민택 on 5/23/24.
//

import SwiftUI
import WebKit

struct NetworkPlayerView: View {
    var body: some View {
        WebView()
    }
}

struct WebView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        if UIDevice.current.systemName == "iOS" {
            return UINavigationController(rootViewController: NetworkPlayerViewController())
        }

        return NetworkPlayerViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

#Preview {
    NetworkPlayerView()
}
