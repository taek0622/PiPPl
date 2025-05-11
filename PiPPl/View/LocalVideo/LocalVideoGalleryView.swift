//
//  LocalVideoGalleryView.swift
//  PiPPl
//
//  Created by 김민택 on 4/30/24.
//

import Photos
import SwiftUI

struct LocalVideoGalleryView: View {
    @AppStorage("updateAlertCount") var updateAlertCount: Int = 0
    @State private var isPermissionAccessable = false
    @State private var updateState: UpdateState = .latest
    @State private var isUpdateAlertOpen = false
    @StateObject private var localVideoLibraryManager = LocalVideoLibraryManager()
    @EnvironmentObject var appVersionManager: AppVersionManager
    @Environment(\.colorScheme) private var colorScheme
    var rowItemCount: Double {
        if UIDevice.current.userInterfaceIdiom == .phone {
            if UIDevice.current.orientation == .portrait {
                return 3
            } else {
                return 5
            }
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            if UIDevice.current.orientation == .portrait {
                return 5
            } else {
                return 7
            }
        }

        return 3
    }

    var body: some View {
        ZStack {
            if !isPermissionAccessable {
                Button(AppText.photoGalleryAccessPermissionButtonText) {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { stat in
                        switch stat {
                        case .notDetermined, .restricted, .denied:
                            isPermissionAccessable = false
                        case .authorized, .limited:
                            Task {
                                await localVideoLibraryManager.configureGallery()
                                isPermissionAccessable = true
                            }
                        @unknown default:
                            break
                        }
                    }
                }
            } else if localVideoLibraryManager.videos.isEmpty {
                Button(AppText.photoGalleryNoVideoButtonText) {
                    Task {
                        await localVideoLibraryManager.configureGallery()
                    }
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width/rowItemCount), spacing: 1), count: Int(rowItemCount)), spacing: 1) {
                        ForEach(localVideoLibraryManager.videos, id: \.id) { video in
                            NavigationLink {
                                LocalVideoPlayView(asset: video.asset)
                                    .toolbar(.hidden, for: .tabBar)
                            } label: {
                                ZStack(alignment: .bottomTrailing) {
                                    AssetImage(asset: video.asset, localVideoLibraryManager: localVideoLibraryManager)
                                        .frame(height: UIScreen.main.bounds.width/rowItemCount)

                                    let duration = Int(video.asset.duration)
                                    Text("\(duration / 60):\(String(format: "%02d", duration % 60))")
                                        .foregroundStyle(.white)
                                        .padding(4)
                                }
                            }
                        }
                    }
                }
            }

            if localVideoLibraryManager.isLoading {
                VStack {
                    ZStack {
                        Color(colorScheme == .light ? #colorLiteral(red: 0.2196078431, green: 0.2196078431, blue: 0.2196078431, alpha: 1) : #colorLiteral(red: 0.5490196078, green: 0.5490196078, blue: 0.5490196078, alpha: 1))
                        Color(colorScheme == .light ? #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 0.82) : #colorLiteral(red: 0.1450980392, green: 0.1450980392, blue: 0.1450980392, alpha: 0.82))
                        VStack {
                            HStack {
                                Text(AppText.videoLoadText)
                                Spacer()
                                Text("\(Int(localVideoLibraryManager.videoLoadingProgress * 100))%")
                            }
                            ProgressView(value: localVideoLibraryManager.videoLoadingProgress)
                        }
                        .padding()
                        .frame(width: UIDevice.current.userInterfaceIdiom == .phone ? UIScreen.main.bounds.width : UIScreen.main.bounds.width / 5 * 3)
                    }
                }
            }
        }
        .toolbar {
            if updateState != .latest {
                Button {
                    isUpdateAlertOpen = true
                } label: {
                    Image(systemName: "arrow.up.square.fill")
                        .foregroundStyle(updateState.updateNotificationColor)
                }

            }
        }
        .alert(updateState.updateAlertTitle, isPresented: $isUpdateAlertOpen) {
            Button(updateState.updateAlertPrimaryAction) {
                let appStoreOpenURL = "itms-apps://itunes.apple.com/app/apple-store/\(appVersionManager.iTunesID)"
                guard let url = URL(string: appStoreOpenURL) else { return }
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }

            if updateState == .recommended || updateState == .available {
                Button(AppText.updateAvailableAlertPostponeAction, role: .cancel) {}
            }
        } message: {
            Text(updateState.updateAlertBody)
        }
        .onAppear {
            switch localVideoLibraryManager.status {
            case .notDetermined, .restricted, .denied:
                isPermissionAccessable = false
            case .authorized, .limited:
                isPermissionAccessable = true
                if localVideoLibraryManager.videos.isEmpty {
                    Task {
                        await localVideoLibraryManager.configureGallery()
                    }
                }
            @unknown default:
                break
            }

            Task {
                updateState = await appVersionManager.checkNewUpdate()

                if updateState == .required && !appVersionManager.isUpdateAlertOpened {
                    isUpdateAlertOpen = true
                    appVersionManager.isUpdateAlertOpened = true
                } else if updateState == .recommended && !appVersionManager.isUpdateAlertOpened {
                    if updateAlertCount == 0 {
                        isUpdateAlertOpen = true
                        appVersionManager.isUpdateAlertOpened = true
                    }

                    updateAlertCount += 1

                    if updateAlertCount == 3 { updateAlertCount = 0 }
                }
            }
        }
    }
}

struct AssetImage: View {
    let asset: PHAsset
    @State private var image: UIImage?
    @ObservedObject var localVideoLibraryManager: LocalVideoLibraryManager

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                ProgressView()
                    .task {
                        image = await localVideoLibraryManager.thumbnail(for: asset)
                    }
            }
        }
    }
}

#Preview {
    NavigationView {
        LocalVideoGalleryView()
    }
}
