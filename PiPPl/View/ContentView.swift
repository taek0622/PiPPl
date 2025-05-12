//
//  ContentView.swift
//  PiPPl
//
//  Created by 김민택 on 4/29/24.
//

import SwiftUI

enum LocalViewSelection: Hashable {
    case playView(Video)
}

enum AppInfoViewSelection: Hashable {
    case noticeView
    case licenseView
}

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
