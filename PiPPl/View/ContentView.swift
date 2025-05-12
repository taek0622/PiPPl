//
//  ContentView.swift
//  PiPPl
//
//  Created by 김민택 on 4/29/24.
//

import SwiftUI

struct ContentView: View {

    @State private var selectedView: ViewSelection = .localVideo
    @State private var localPath = NavigationPath()
    @State private var appInfoPath = NavigationPath()
    @StateObject var localVideoLibraryManager = LocalVideoLibraryManager()

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            TabView(selection: $selectedView) {
                NavigationStack(path: $localPath) {
                    LocalVideoGalleryView(localPath: $localPath, localVideoLibraryManager: localVideoLibraryManager)
                        .navigationTitle(AppText.localVideo)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label(AppText.localVideo, systemImage: "play.square") }
                .tag(ViewSelection.localVideo)

                NetworkPlayerView()
                    .tabItem { Label(AppText.networkVideo, systemImage: "globe") }
                    .tag(ViewSelection.networkVideo)

                NavigationStack(path: $appInfoPath) {
                    AppInfoView(appInfoPath: $appInfoPath)
                        .navigationTitle(AppText.appInfo)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tabItem { Label(AppText.appInfo, systemImage: "info.circle") }
                .tag(ViewSelection.appInfo)
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            NavigationSplitView {
                List {
                    Button {
                        selectedView = .localVideo
                    } label: {
                        Label(AppText.localVideo, systemImage: "play.square")
                    }

                    Button {
                        selectedView = .networkVideo
                    } label: {
                        Label(AppText.networkVideo, systemImage: "globe")
                    }

                    Button {
                        selectedView = .appInfo
                    } label: {
                        Label(AppText.appInfo, systemImage: "info.circle")
                    }
                }
                .listStyle(.plain)
            } detail: {
                VStack {
                    switch selectedView {
                        case .localVideo:
                            NavigationStack(path: $localPath) {
                                LocalVideoGalleryView(localPath: $localPath, localVideoLibraryManager: localVideoLibraryManager)
                                    .navigationTitle(AppText.localVideo)
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        case .networkVideo:
                            NavigationStack {
                                NetworkPlayerView()
                                    .navigationTitle(AppText.networkVideo)
                                    .toolbar(.hidden)
                            }
                        case .appInfo:
                            NavigationStack(path: $appInfoPath) {
                                AppInfoView(appInfoPath: $appInfoPath)
                                    .navigationTitle(AppText.appInfo)
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                    }
                }
                .onChange(of: selectedView) { value in
                    switch value {
                        case .localVideo:
                            appInfoPath = .init()
                        case .networkVideo:
                            localPath = .init()
                            appInfoPath = .init()
                        case .appInfo:
                            localPath = .init()
                    }
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
