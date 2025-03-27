//
//  ContentView.swift
//  PiPPl
//
//  Created by 김민택 on 4/29/24.
//

import SwiftUI

struct ContentView: View {
    let localVideoGalleryView = LocalVideoGalleryView()
    let networkPlayerView = NetworkPlayerView()
    let appInfoView = AppInfoView()

    var body: some View {
        if UIDevice.current.systemName == "iOS" {
            TabView {
                NavigationStack {
                    localVideoGalleryView
                        .navigationTitle("로컬 비디오")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label("로컬 비디오", systemImage: "play.square") }
                networkPlayerView
                    .tabItem { Label("네트워크 비디오", systemImage: "globe") }
                NavigationStack {
                    appInfoView
                }
                .tabItem { Label("앱 정보", systemImage: "info.circle") }
            }
        } else {
            NavigationSplitView {
                NavigationLink {
                    localVideoGalleryView
                } label: {
                    Label("로컬 비디오", systemImage: "play.squre")
                }
                NavigationLink {
                    networkPlayerView
                } label: {
                    Label("네트워크 비디오", systemImage: "globe")
                }
                NavigationLink {
                    appInfoView
                } label: {
                    Label("앱 정보", systemImage: "info.circle")
                }
            } detail: {
                localVideoGalleryView
            }
        }
    }
}

#Preview {
    ContentView()
}
