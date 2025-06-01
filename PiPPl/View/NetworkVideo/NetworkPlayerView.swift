//
//  NetworkPlayerView.swift
//  PiPPl
//
//  Created by 김민택 on 5/23/24.
//

import SwiftUI

struct NetworkPlayerView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var searchingText = "https://www.google.com/"
    @State private var isSubmitted = false
    @State private var isPausedVideo = false

    var body: some View {
        WebView(searchingText: $searchingText, isSubmitted: $isSubmitted, isPausedVideo: $isPausedVideo)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    TextField(AppText.searchFieldPlaceholder, text: $searchingText)
                        .padding(4)
                        .background(Color(UIColor(white: colorScheme == .light ? 0.9 : 0.7, alpha: 1)))
                        .clipShape(.rect(cornerRadius: 8))
                        .onSubmit {
                            isSubmitted = true
                        }
                }
            }
            .onDisappear {
                isPausedVideo = true
            }
    }
}

#Preview {
    NetworkPlayerView()
}
