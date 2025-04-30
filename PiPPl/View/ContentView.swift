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
                        .navigationTitle(AppText.localVideo)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label(AppText.localVideo, systemImage: "play.square") }
                networkPlayerView
                    .tabItem { Label(AppText.networkVideo, systemImage: "globe") }
                NavigationStack {
                    appInfoView
                        .navigationTitle(AppText.appInfo)
                }
                .tabItem { Label(AppText.appInfo, systemImage: "info.circle") }
            }
        } else {
            NavigationSplitView {
                List {
                    NavigationLink {
                        NavigationStack {
                            localVideoGalleryView
                                .navigationTitle(AppText.localVideo)
                        }
                    } label: {
                        Label(AppText.localVideo, systemImage: "play.square")
                    }
                    NavigationLink {
                        networkPlayerView
                    } label: {
                        Label(AppText.networkVideo, systemImage: "globe")
                    }
                    NavigationLink {
                        NavigationStack {
                            appInfoView
                                .navigationTitle(AppText.appInfo)
                        }
                    } label: {
                        Label(AppText.appInfo, systemImage: "info.circle")
                    }
                }
                .listStyle(.plain)
            } detail: {
                NavigationStack {
                    localVideoGalleryView
                        .navigationTitle(AppText.localVideo)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
