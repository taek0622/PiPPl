//
//  ContentView.swift
//  PiPPl
//
//  Created by 김민택 on 4/29/24.
//

import SwiftUI

struct ContentView: View {
    enum ViewSelection {
        case localVideo
        case networkVideo
        case appInfo
    }

    @State private var selectedView: ViewSelection = .localVideo

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $selectedView) {
                NavigationStack {
                    LocalVideoGalleryView(localPath: $localPath, localVideoLibraryManager: localVideoLibraryManager)
                        .navigationTitle(AppText.localVideo)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label(AppText.localVideo, systemImage: "play.square") }
                .tag(ViewSelection.localVideo)

                NetworkPlayerView()
                    .tabItem { Label(AppText.networkVideo, systemImage: "globe") }
                    .tag(ViewSelection.networkVideo)

                NavigationStack {
                    AppInfoView(appInfoPath: $appInfoPath)
                        .navigationTitle(AppText.appInfo)
                }
                .tabItem { Label(AppText.appInfo, systemImage: "info.circle") }
                .tag(ViewSelection.appInfo)
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
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
        } else {
            Text(AppText.notSupportDevice)
        }
    }
}

#Preview {
    ContentView()
}
